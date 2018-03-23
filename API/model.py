from sqlalchemy.orm import relationship
from database import db
from sqlalchemy import String, Integer


class Thing(db.Model):
    __tablename__ = 'thing'

    id = db.Column(db.Integer, primary_key=True)
    item1 = db.Column(String(10))
    item2 = db.Column(String(20))
    book_id = db.Column(Integer, db.ForeignKey('book.id'))


class Book(db.Model):
    __tablename__ = 'book'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(String(20))
    things = db.relationship("Thing", backref="book", cascade='all, delete-orphan')
