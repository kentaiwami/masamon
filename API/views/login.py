from flask import Blueprint

login = Blueprint('login', __name__)

@login.route('/login')
def index():
    # input     企業コード、ユーザコード、ユーザ名、パスワード
    # output    成功、失敗

    # リクエストパース
    # ログイン処理
    # リターン
    return '<h1>Hello</h1>'
