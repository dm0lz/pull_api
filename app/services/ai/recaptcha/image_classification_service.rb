class Ai::Recaptcha::ImageClassificationService < BaseService
  def initialize(img_base64:, tiles_nb:, keyword:)
    @img_base64 = img_base64
    @tiles_nb = tiles_nb
    @keyword = keyword
  end

  def call
    puts python_script
    RuntimeExecutor::PythonService.new.call(python_script)
  end

  private

  def python_script
    <<-PYTHON
      import base64
      import tempfile
      import os
      import json
      import sys
      import contextlib
      from PIL import Image
      from ultralytics import YOLO
      import logging
      import ipdb
      import torch

      logging.getLogger("ultralytics").setLevel(logging.CRITICAL)

      # Input vars
      img_base64 = "#{@img_base64}"
      tiles_nb = int(#{@tiles_nb})
      keyword = "#{@keyword}".lower()

      # Decode the base64 image
      image_data = base64.b64decode(img_base64)

      with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as temp_file:
          temp_file.write(image_data)
          temp_path = temp_file.name

      # Open and resize the image to a larger resolution
      image = Image.open(temp_path)
      large_resolution = 1920  # Target resolution for the smaller dimension
      image = image.resize(
          (large_resolution, large_resolution),
          Image.Resampling.LANCZOS  # High-quality resampling
      )
      width, height = image.size

      # Calculate grid dimensions
      cols = rows = int(tiles_nb ** 0.5)
      tile_width = width // cols
      tile_height = height // rows

      model = YOLO("yolov8x-cls.pt")

      results = []

      for row in range(rows):
          for col in range(cols):
              left = col * tile_width
              top = row * tile_height
              right = left + tile_width
              bottom = top + tile_height
              tile = image.crop((left, top, right, bottom))

              # Resize tile to 640x640 for YOLO analysis
              tile = tile.resize(
                  (640, 640),
                  Image.Resampling.LANCZOS  # High-quality resampling
              )

              with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as tile_file:
                  tile.save(tile_file.name)  # Save as PNG for lossless quality
                  tile_path = tile_file.name

              preds = model(tile_path, conf=0.01)[0]

              # Get top-5 class indices
              # top5_ids = preds.probs.top5  # List of integers
              probs_tensor = preds.probs.data
              top15_ids = torch.topk(probs_tensor, 15).indices.tolist()
              names = preds.names          # List or dict of class names
              # Check if keyword is in any of the top-5 class names
              found = any(
                keyword in names[class_id].lower().replace("_", " ")
                for class_id in top15_ids
              )

              # names = preds.names
              # classes = preds.boxes.cls.tolist() if preds.boxes.cls is not None else []
              # ipdb.set_trace()

              # found = any(keyword in names[int(cls)].lower() for cls in classes)
              results.append(found)

              os.remove(tile_path)

      os.remove(temp_path)

      print(json.dumps(results), flush=True)
    PYTHON
  end
end
