from flask import Blueprint, render_template, request

main = Blueprint("main", __name__)

@main.route("/")
def index():
    return render_template("index.html", test="testing")


view2 = Blueprint("view2", __name__)
@view2.route("/view2")
def index():
    return render_template("view2.html", test="testing")

check_status = Blueprint("check_status", __name__)
@check_status.route("/check_status", methods=['POST'])
def index():
    data = request.form
    return render_template("check_status.html", test="testing", data=data)
