from flask import Blueprint, request, jsonify
from jsonschema import validate, ValidationError


app = Blueprint('login', __name__)


@app.route('/api/v1/login', methods=['POST'])
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

    # ログイン処理
    return jsonify({'msg': 'OK'})
