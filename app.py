from flask import Flask

import json
import time


app = Flask(__name__)

@app.route("/")
def get_timestamp():
    response = {
        "message": "Automate all the things!",
        "timestamp": time.time()
    }

    return json.dumps(response)