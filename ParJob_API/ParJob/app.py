from flask import Flask
from ParJob.database import init_db
import ParJob.models


def create_app():
    app_tmp = Flask(__name__)
    app_tmp.config.from_object('ParJob.config.Config')

    init_db(app_tmp)

    return app_tmp

app = create_app()

@app.route('/')
def hello_world():
    return 'Hello, World!'
