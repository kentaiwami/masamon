from flask import Flask
from ParJob.database import init_db
from ParJob.database import db
from flask_admin import Admin
from flask_admin.contrib.sqla import ModelView
from .models import Company, Employee
from .config import secret_key


def create_app():
    app_tmp = Flask(__name__)
    app_tmp.secret_key = secret_key
    app_tmp.config.from_object('ParJob.config.Config')

    init_db(app_tmp)

    admin = Admin(app_tmp, name='microblog', template_mode='bootstrap3')
    admin.add_view(ModelView(Company, db.session))
    admin.add_view(ModelView(Employee, db.session))

    return app_tmp

app = create_app()

@app.route('/')
def hello_world():
    return 'Hello, World!'
