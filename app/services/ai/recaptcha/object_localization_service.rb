class Ai::Recaptcha::ObjectLocalizationService < BaseService
  def initialize(img_base64:, tiles_nb:, keyword:)
    @img_base64 = img_base64
    @tiles_nb = tiles_nb
    @keyword = keyword
  end

  def call
    puts(python_script)
    RuntimeExecutor::PythonService.new.call(python_script)
  end

  private

  def python_script
    <<-PYTHON
      import base64
      import tempfile
      import os
      import json
      import math
      from PIL import Image
      import torch
      from transformers import AutoProcessor, GroundingDinoForObjectDetection

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

      # Load processor and model
      processor = AutoProcessor.from_pretrained("IDEA-Research/grounding-dino-base")
      model = GroundingDinoForObjectDetection.from_pretrained("IDEA-Research/grounding-dino-base")

      inputs = processor(images=image, text=keyword, return_tensors="pt")
      outputs = model(**inputs)

      target_sizes = torch.tensor([image.size[::-1]])
      results = processor.image_processor.post_process_object_detection(
          outputs, threshold=0.1, target_sizes=target_sizes
      )[0]

      tile_flags = [False] * tiles_nb

      for score, label_id, box in zip(results["scores"], results["labels"], results["boxes"]):
          x1, y1, x2, y2 = box.tolist()

          for row in range(grid_size):
              for col in range(grid_size):
                  tile_index = row * grid_size + col
                  tile_x1 = col * tile_w
                  tile_y1 = row * tile_h
                  tile_x2 = tile_x1 + tile_w
                  tile_y2 = tile_y1 + tile_h

                  # Compute intersection
                  inter_x1 = max(x1, tile_x1)
                  inter_y1 = max(y1, tile_y1)
                  inter_x2 = min(x2, tile_x2)
                  inter_y2 = min(y2, tile_y2)

                  inter_area = max(0, inter_x2 - inter_x1) * max(0, inter_y2 - inter_y1)

                  # Mark as True if there's any overlap
                  if inter_area > 0:
                      tile_flags[tile_index] = True

      os.remove(temp_path)
      print(json.dumps(tile_flags), flush=True)
    PYTHON
  end
end
