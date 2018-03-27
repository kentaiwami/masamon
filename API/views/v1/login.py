from flask import Blueprint, request, jsonify
from jsonschema import validate, ValidationError
from werkzeug.security import check_password_hash
from model import *
from database import session


app = Blueprint('login', __name__)


@app.route('/api/v1/login', methods=['POST'])
def login():
    schema = {'type': 'object',
              'properties':
                  {'user_code': {'type': 'string', 'minLength': 7, 'maxLength': 7},
                   'password': {'type': 'string', 'minLength': 7}
                   },
              'required': ['user_code', 'password']
              }

    try:
        validate(request.json, schema)
    except ValidationError as e:
        return jsonify({'msg': e.message}), 400

    user = session.query(Employee).filter(Employee.code == request.json['user_code']).first()
    session.close()

    if check_password_hash(user.password, request.json['password']):
        return jsonify({'msg': 'OK'}), 200
    else:
        return jsonify({'msg': 'ログインに失敗しました'}), 404
