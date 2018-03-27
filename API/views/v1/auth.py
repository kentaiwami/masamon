from flask import Blueprint, request, jsonify
from jsonschema import validate, ValidationError
from werkzeug.security import generate_password_hash
from model import *
from database import session


app = Blueprint('auth', __name__)


@app.route('/api/v1/auth', methods=['POST'])
def login():
    schema = {'type': 'object',
              'properties':
                  {'company_code': {'type': 'string', 'minLength': 7, 'maxLength': 7},
                   'user_code': {'type': 'string', 'minLength': 7, 'maxLength': 7},
                   'username': {'type': 'string', 'minLength': 1},
                   'password': {'type': 'string', 'minLength': 7}
                   },
              "required": ["company_code", 'user_code', 'username', 'password']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        return jsonify({'msg': e.message}), 400

    user = session.query(Employee).join(Company.employees)\
        .filter(Company.code == request.json['company_code'],
                Employee.name == request.json['username'],
                Employee.code == request.json['user_code'],
                Employee.password == request.json['password']).first()

    if user:
        user.password = generate_password_hash(request.json['password'])
        session.commit()
        session.close()
        return jsonify({'msg': 'OK'}), 200
    else:
        session.close()
        return jsonify({'msg': 'ログインに失敗しました'}), 404
