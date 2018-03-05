from datetime import datetime
from ParJob.database import db


class Company(db.Model):
    __tablename__ = 'company'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False, unique=True)
    code = db.Column(db.String(255), nullable=False, unique=True)

    employees = db.relationship('Employee', backref='company', lazy='dynamic')
    shift_tables = db.relationship('ShiftTable', backref='company', lazy='dynamic')


class ShiftTable(db.Model):
    __tablename__ = 'shifttable'

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    path = db.Column(db.String(255), nullable=False)
    company_id = db.Column(db.Integer, db.ForeignKey('company.id'), nullable=False)


class Employee(db.Model):
    __tablename__ = 'employee'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    code = db.Column(db.String(255), nullable=False, unique=True)
    password = db.Column(db.String(255), nullable=False)
    daytime_start = db.Column(db.Time, nullable=True)
    daytime_end = db.Column(db.Time, nullable=True)
    daytime_hourly_wage = db.Column(db.Integer, nullable=True)
    night_start = db.Column(db.Time, nullable=True)
    night_end = db.Column(db.Time, nullable=True)
    night_hourly_wage = db.Column(db.Integer, nullable=True)
    company_id = db.Column(db.Integer, db.ForeignKey('company.id'))
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.now)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.now, onupdate=datetime.now)
