from datetime import datetime
from ParJob.database import db


class Employee(db.Model):

    __tablename__ = 'Employee'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    code = db.Column(db.String(255), nullable=False)
    password = db.Column(db.String(255), nullable=False)
    daytime_start = db.Column(db.Time, nullable=True)
    daytime_end = db.Column(db.Time, nullable=True)
    daytime_hourly_wage = db.Column(db.Integer, nullable=True)
    night_start = db.Column(db.Time, nullable=True)
    night_end = db.Column(db.Time, nullable=True)
    night_hourly_wage = db.Column(db.Integer, nullable=True)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.now)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.now, onupdate=datetime.now)
