from flask import Flask

from .events import socketio

from .routes import main, view2, check_status

def create_app():
    app = Flask(__name__, static_url_path='/static')
    app.config["DEBUG"] = True
    app.config["SECRET_KEY"] = "secretkey"
    app.url_map.strict_slashes = False

    app.register_blueprint(main)
    app.register_blueprint(view2)
    app.register_blueprint(check_status)

    socketio.init_app(app)

    return app