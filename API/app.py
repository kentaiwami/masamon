from database import init_db, db
from flask import Flask, Response, redirect
from flask_basicauth import BasicAuth
from flask_admin import Admin
from flask_admin.contrib import sqla
from werkzeug.exceptions import HTTPException
from model import Thing, Book
from flask_migrate import Migrate
from secret import secret_key
from views.hello import hello


class AuthException(HTTPException):
    def __init__(self, message):
        super().__init__(message, Response(
            message, 401,
            {'WWW-Authenticate': 'Basic realm="Login Required"'}
        ))


class ModelView(sqla.ModelView):
    def is_accessible(self):
        if not basic_auth.authenticate():
            raise AuthException('Not authenticated. Refresh the page.')
        else:
            return True

    def inaccessible_callback(self, name, **kwargs):
        return redirect(basic_auth.challenge())


def init_app():
    app_obj = Flask(__name__)
    app_obj.config.from_pyfile('config.cfg')
    app_obj.secret_key = secret_key
    app_obj.debug = True

    init_db(app_obj)
    init_admin(app_obj)
    regist_bp(app_obj)

    return app_obj


def init_admin(app_obj):
    admin = Admin(app_obj, name='ParJob', template_mode='bootstrap3')
    admin.add_view(ModelView(Thing, db.session))
    admin.add_view(ModelView(Book, db.session))


def regist_bp(app_obj):
    app_obj.register_blueprint(hello)


app = init_app()
basic_auth = BasicAuth(app)
migrate = Migrate(app, db)


@app.route('/logout')
def Logout():
    raise AuthException('Successfully logged out.')


@app.route('/')
@app.route('/index')
def index():
    return 'This is index page'
