from database import init_db
from flask import Flask, Response, redirect
from flask_basicauth import BasicAuth
from flask_admin import Admin
from flask_admin.contrib import sqla
from werkzeug.exceptions import HTTPException
from flask_migrate import Migrate
from model import *
from secret import secret_key
from views.v1 import login


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

    init_db(app_obj)
    init_admin(app_obj)
    regist_bp(app_obj)

    return app_obj


def init_admin(app_obj):
    admin = Admin(app_obj, name='ParJob', template_mode='bootstrap3')
    admin.add_view(ModelView(Company, db.session))

    admin.add_view(ModelView(Employee, db.session, category='Employee'))
    admin.add_view(ModelView(Role, db.session, category='Employee'))
    admin.add_view(ModelView(Salary, db.session, category='Employee'))

    admin.add_view(ModelView(Shift, db.session, category='Shift'))
    admin.add_view(ModelView(ShiftCategory, db.session, category='Shift'))
    admin.add_view(ModelView(ShiftTable, db.session, category='Shift'))
    admin.add_view(ModelView(EmployeeShift, db.session, category='Shift'))

    admin.add_view(ModelView(Comment, db.session))
    admin.add_view(ModelView(ColorScheme, db.session))
    admin.add_view(ModelView(History, db.session))


def regist_bp(app_obj):
    app_obj.register_blueprint(login.app)


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
