from flask import Blueprint
from flask_login import login_user, logout_user


app = Blueprint("auth", __name__, url_prefix="/auth")
