from flask import Flask

import json
import time


app = Flask(__name__)

@app.route("/")
def index():
    return "<p>Yusuf's Liatrio App</p>"

@app.route("/timestamp")
def get_timestamp():
    response = {
        "message": "Automate all the things!",
        "timestamp": time.time()
    }

    return json.dumps(response)

@app.route("/_health")
def health_check():
    return "<p>running</p>"