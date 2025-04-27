class Ai::Recaptcha::ObjectLocalizationService < BaseService
  def initialize(img_base64:, tiles_nb:, keyword:)
    @img_base64 = img_base64
    @tiles_nb = tiles_nb
    @keyword = keyword
  end

  def call
    mutex = Mutex.new
    mutex.synchronize do
      puts(python_script)
      RuntimeExecutor::PythonService.new.call(python_script)
    end
  end

  def python_script
    <<-PYTHON
      import base64
      import tempfile
      import os
      import json
      import math
      from PIL import Image, ImageDraw
      import torch
      from transformers import AutoProcessor, GroundingDinoForObjectDetection
      import ipdb

      img_base64 = "#{@img_base64}"
      tiles_nb = int(#{@tiles_nb})
      keyword = "#{@keyword}".lower()

      # Decode base64 image
      image_data = base64.b64decode(img_base64)
      with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as temp_file:
          temp_file.write(image_data)
          temp_path = temp_file.name

      image = Image.open(temp_path).convert("RGB")
      width, height = image.size
      grid_size = int(math.sqrt(tiles_nb))
      tile_w = width / grid_size
      tile_h = height / grid_size

      # Load model and processor
      processor = AutoProcessor.from_pretrained("IDEA-Research/grounding-dino-base")
      model = GroundingDinoForObjectDetection.from_pretrained("IDEA-Research/grounding-dino-base")

      inputs = processor(images=image, text=keyword, return_tensors="pt")
      outputs = model(**inputs)

      target_sizes = torch.tensor([image.size[::-1]])
      results = processor.image_processor.post_process_object_detection(
          outputs, threshold=0.15, target_sizes=target_sizes
      )[0]

      tile_flags = [False] * tiles_nb

      # Prepare overlay for green highlight
      overlay = Image.new("RGBA", image.size, (0, 0, 0, 0))
      overlay_draw = ImageDraw.Draw(overlay)
      image = image.convert("RGBA")
      draw = ImageDraw.Draw(image)

      # Draw grid in white
      for i in range(1, grid_size):
          x = i * tile_w
          draw.line([(x, 0), (x, height)], fill="white", width=1)
          y = i * tile_h
          draw.line([(0, y), (width, y)], fill="white", width=1)

      # Loop through all detected boxes
      for score, label_id, box in zip(results["scores"], results["labels"], results["boxes"]):
          x1, y1, x2, y2 = box.tolist()

          # Draw bounding box (red outline)
          draw.rectangle([x1, y1, x2, y2], outline="red", width=3)

          # Check all grid tiles for intersection
          for row in range(grid_size):
              for col in range(grid_size):
                  tile_index = row * grid_size + col
                  tile_x1 = col * tile_w
                  tile_y1 = row * tile_h
                  tile_x2 = tile_x1 + tile_w
                  tile_y2 = tile_y1 + tile_h

                  inter_x1 = max(x1, tile_x1)
                  inter_y1 = max(y1, tile_y1)
                  inter_x2 = min(x2, tile_x2)
                  inter_y2 = min(y2, tile_y2)
                  inter_area = max(0, inter_x2 - inter_x1) * max(0, inter_y2 - inter_y1)

                  tile_area = tile_w * tile_h
                  if inter_area / tile_area > 0.15:
                      tile_flags[tile_index] = True
                      overlay_draw.rectangle(
                          [tile_x1, tile_y1, tile_x2, tile_y2],
                          fill=(0, 255, 0, 100)
                      )

      # Composite overlay onto image
      image = Image.alpha_composite(image, overlay)

      # Save debug image
      vis_path = temp_path.replace(".png", "_boxes.png")
      image.save(vis_path)

      # Optional: print debug image path
      # print("Saved visualization to:", vis_path, flush=True)
      # ipdb.set_trace()

      os.remove(temp_path)
      os.remove(vis_path)

      print(json.dumps(tile_flags), flush=True)
    PYTHON
  end
end
