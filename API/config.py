secret_key = 'secret key hogehoge...'
database = {
    'username': 'root',
    'password': 'root',
    'host': 'localhost',
    'name': 'parjob'
}


class BaseConfig(object):
    BASIC_AUTH_USERNAME = 'username'
    BASIC_AUTH_PASSWORD = 'password'
    SQLALCHEMY_TRACK_MODIFICATIONS = True
    SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://root:root@localhost/parjob'
