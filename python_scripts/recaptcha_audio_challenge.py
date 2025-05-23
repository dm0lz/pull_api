import json
import requests
import tempfile
import os
from transformers import pipeline

response = requests.get("https://freereadtext.com/audio/english-male.wav", stream=True)
response.raise_for_status()

with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as temp_audio:
    for chunk in response.iter_content(chunk_size=8192):
        temp_audio.write(chunk)
    temp_path = temp_audio.name

pipe = pipeline("automatic-speech-recognition", model="openai/whisper-large-v3-turbo")
output = pipe(temp_path)
os.remove(temp_path)

print(json.dumps(output, indent=2))
