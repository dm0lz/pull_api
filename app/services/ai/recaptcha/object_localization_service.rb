class Ai::Recaptcha::ObjectLocalizationService < BaseService
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
      import math
      import ipdb

      logging.getLogger("ultralytics").setLevel(logging.CRITICAL)

      # Input vars
      img_base64 = "#{@img_base64}"
      tiles_nb = int(#{@tiles_nb})
      keyword = "#{@keyword}".lower()

      def get_tiles_with_object(image_path, tiles_nb, keyword, model_path="yolov8x.pt", conf_threshold=0.5):
          keyword = keyword.lower()
          model = YOLO(model_path)

          # Run YOLO detection
          results = model(image_path, conf=conf_threshold)[0]
          names = results.names
          boxes = results.boxes

          # Init result list
          tile_flags = [False] * tiles_nb

          if boxes is None or boxes.cls is None:
              return tile_flags

          # Open image and get dimensions
          image = Image.open(image_path)
          width, height = image.size

          # Determine grid size
          grid_size = int(math.sqrt(tiles_nb))
          tile_w = width / grid_size
          tile_h = height / grid_size

          for i, cls_id in enumerate(boxes.cls.tolist()):
              label = names[int(cls_id)].lower().replace("_", " ")
              if keyword not in label:
                  continue

              x1, y1, x2, y2 = boxes.xyxy[i].tolist()

              # Compute tile indices for the bounding box
              col_start = int(x1 // tile_w)
              col_end = int(x2 // tile_w)
              row_start = int(y1 // tile_h)
              row_end = int(y2 // tile_h)

              for row in range(row_start, row_end + 1):
                  for col in range(col_start, col_end + 1):
                      tile_index = row * grid_size + col
                      if 0 <= tile_index < tiles_nb:
                          tile_flags[tile_index] = True

          return tile_flags

      image_data = base64.b64decode(img_base64)
      with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as temp_file:
          temp_file.write(image_data)
          temp_path = temp_file.name

      tiles = get_tiles_with_object(temp_path, tiles_nb, keyword)
      print(json.dumps(tiles), flush=True)
    PYTHON
  end
end
