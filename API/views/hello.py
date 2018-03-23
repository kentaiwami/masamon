from flask import Blueprint

hello = Blueprint('hello', __name__)

@hello.route('/hello')
def hello_index():
    return '<h1>Hello</h1>'
