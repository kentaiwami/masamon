from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from sqlalchemy import create_engine
from sqlalchemy.orm import scoped_session, sessionmaker
from secret import database

db = SQLAlchemy()

DATABASE = 'mysql+pymysql://%s:%s@%s/%s' % (
        database['username'],
        database['password'],
        database['host'],
        database['name'],
    )

ENGINE = create_engine(
    DATABASE,
    encoding="utf-8",
    echo=True
)

session = scoped_session(sessionmaker(autocommit=False, autoflush=False, bind=ENGINE))


def init_db(app):
    db.init_app(app)
    Migrate(app, db)
