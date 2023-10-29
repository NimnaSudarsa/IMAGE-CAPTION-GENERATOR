from flask import Flask, request, send_from_directory
import base64

from flask_cors import CORS

from app import generateCaption
from speech import textToSpeech

app = Flask(__name__)

CORS(app)


@app.get('/')
def index_page():
    return send_from_directory('web', 'index.html')


@app.get('/live')
def status():
    return "OK"


@app.get('/audio/<id>')
def get_audio(id):
    return send_from_directory('temp/audio', id + '.wav')


@app.get('/<path:path>')
def _static(path):
    return send_from_directory('web', path)


@app.post("/api/generate")
def get_image_caption():
    image_in_base64 = request.get_json()['image']
    extension = request.get_json()['extension']

    file_path = "temp/images/image.{}".format(extension)

    with open(file_path, "wb") as fh:
        fh.write(base64.urlsafe_b64decode(image_in_base64))

    caption = generateCaption([file_path])
    id = textToSpeech(caption[0])

    response = {
        'caption': caption[0],
        'audio_id': id
    }

    return response


if __name__ == "__main__":
    port = 5000
    app.run(host='0.0.0.0', port=port)
