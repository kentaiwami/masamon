from flask import Flask
from flask_admin import Admin
from .api import *
from .auth import *

application = Flask(__name__)

modules_define = [api.app, auth.app]
for app in modules_define:
    application.register_blueprint(app)

admin = Admin(application)
