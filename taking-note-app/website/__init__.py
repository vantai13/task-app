from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from os import path
from flask_login import LoginManager
<<<<<<< HEAD
=======
import random
import os

# 1. Danh sách màu
COLOR_LIST = [
    '#E57373',  # Red
    '#81C784',  # Green
    '#64B5F6',  # Blue
    '#FFD54F',  # Yellow
    '#BA68C8',  # Purple
    '#FF8A65',  # Orange
]

# 2. Hàm lấy màu
def get_server_color():
    """
    Lấy màu cho server.
    Ưu tiên 1: Lấy từ biến môi trường 'SERVER_COLOR'.
    Ưu tiên 2: Nếu không có, chọn ngẫu nhiên một màu.
    """
    color = os.environ.get('SERVER_COLOR')
    if color:
        return color
    return random.choice(COLOR_LIST)

# 3. Đặt màu MỘT LẦN DUY NHẤT khi server khởi động
SERVER_COLOR = get_server_color()
>>>>>>> 19ca715 (add random color)

db = SQLAlchemy()
DB_NAME = "database.db"

<<<<<<< HEAD

=======
>>>>>>> 19ca715 (add random color)
def create_app():
    app = Flask(__name__)
    app.config['SECRET_KEY'] = 'hjshjhdjah kjshkjdhjs'
    app.config['SQLALCHEMY_DATABASE_URI'] = f'sqlite:///{DB_NAME}'
    db.init_app(app)

    from .views import views
    from .auth import auth

    app.register_blueprint(views, url_prefix='/')
    app.register_blueprint(auth, url_prefix='/')

    from .models import User, Note
    
    with app.app_context():
        db.create_all()

    login_manager = LoginManager()
    login_manager.login_view = 'auth.login'
    login_manager.init_app(app)

    @login_manager.user_loader
    def load_user(id):
        return User.query.get(int(id))

<<<<<<< HEAD
=======
    @app.context_processor
    def inject_server_color():
        """Tiêm biến server_color vào mọi template"""
        return dict(server_color=SERVER_COLOR)

>>>>>>> 19ca715 (add random color)
    return app


def create_database(app):
    if not path.exists('website/' + DB_NAME):
        db.create_all(app=app)
        print('Created Database!')
