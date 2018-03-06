from datetime import datetime
from ParJob.database import db


class Company(db.Model):
    __tablename__ = 'company'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False, unique=True)
    code = db.Column(db.String(255), nullable=False, unique=True)

    employees = db.relationship('Employee', backref='company', lazy='dynamic', cascade='all, delete-orphan')
    shift_tables = db.relationship('ShiftTable', backref='company', lazy='dynamic', cascade='all, delete-orphan')
    shift_categories = db.relationship('ShiftCategory', backref='company', lazy='dynamic', cascade='all, delete-orphan')

    def __repr__(self):
        return '{}({})'.format(self.name, self.code)


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
    company_id = db.Column(db.Integer, db.ForeignKey('company.id'), nullable=False)
    role_id = db.Column(db.Integer, db.ForeignKey('role.id'), nullable=False)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.now)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.now, onupdate=datetime.now)

    salaries = db.relationship('Salary', backref='employee', lazy='dynamic', cascade='all, delete-orphan')
    color_schemes = db.relationship('ColorScheme', backref='employee', lazy='dynamic', cascade='all, delete-orphan')
    employee_shifts = db.relationship('EmployeeShift', backref='employee', lazy='dynamic', cascade='all, delete-orphan')

    def __repr__(self):
        return self.name


class Role(db.Model):
    __tablename__ = 'role'

    id = db.Column(db.Integer, primary_key=True)
    role = db.Column(db.String(255), nullable=False)

    employees = db.relationship('Employee', backref='role', lazy='dynamic', cascade='all, delete-orphan')

    def __repr__(self):
        return self.role


class ShiftTable(db.Model):
    __tablename__ = 'shifttable'

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    path = db.Column(db.String(255), nullable=False)
    company_id = db.Column(db.Integer, db.ForeignKey('company.id'), nullable=False)

    salaries = db.relationship('Salary', backref='shifttable', lazy='dynamic', cascade='all, delete-orphan')
    employee_shifts = db.relationship('EmployeeShift', backref='shifttable', lazy='dynamic', cascade='all, delete-orphan')

    def __repr__(self):
        return '{}'.format(self.title)


class Salary(db.Model):
    __tablename__ = 'salary'

    id = db.Column(db.Integer, primary_key=True)
    pay = db.Column(db.Integer, nullable=True)
    employee_id = db.Column(db.Integer, db.ForeignKey('employee.id'), nullable=False)
    shifttable_id = db.Column(db.Integer, db.ForeignKey('shifttable.id'), nullable=False)


class ShiftCategory(db.Model):
    __tablename__ = 'shiftcategory'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    company_id = db.Column(db.Integer, db.ForeignKey('company.id'), nullable=False)

    shifts = db.relationship('Shift', backref='shiftcategory', lazy='dynamic', cascade='all, delete-orphan')


class Shift(db.Model):
    __tablename__ = 'shift'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    shift_category_id = db.Column(db.Integer, db.ForeignKey('shiftcategory.id'), nullable=False)

    employee_shifts = db.relationship('EmployeeShift', backref='shift', lazy='dynamic', cascade='all, delete-orphan')

class EmployeeShift(db.Model):
    __tablename__ = 'employeeshift'

    id = db.Column(db.Integer, primary_key=True)
    date = db.Column(db.Date, nullable=False)
    shift_id = db.Column(db.Integer, db.ForeignKey('shift.id'), nullable=False)
    employee_id = db.Column(db.Integer, db.ForeignKey('employee.id'), nullable=False)
    shift_table_id = db.Column(db.Integer, db.ForeignKey('shifttable.id'), nullable=False)


class ColorScheme(db.Model):
    __tablename__ = 'colorscheme'

    id = db.Column(db.Integer, primary_key=True)
    color = db.Column(db.String(255), nullable=False)
    employee_id = db.Column(db.Integer, db.ForeignKey('employee.id'), nullable=False)