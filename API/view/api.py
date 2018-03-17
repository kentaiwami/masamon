from flask import Blueprint

app = Blueprint("api", __name__, url_prefix="/api")

@app.route('/v1/test')
def hello_world():
    return 'Hello World!'
