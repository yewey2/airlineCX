from flask_socketio import emit
from .extensions import socketio
from flask import request
from app.smart_contract import get_sample_data

local_data = {}


from timeit import default_timer as timer

# request.sid => The session id of the user 
# can use it to identify if it is the same user

all_users = dict()

@socketio.on("connect")
def handle_connect():
    print("Connected Python")

@socketio.on("my event")
def handle_my_event(data=dict()):
    print('data is', data)

@socketio.on("get_data")
def handle_get_data():
    data = get_sample_data()
    print('data is', data)
    emit('contract_get_data', {'data':data})

@socketio.on("add_data_local")
def handle_add_data_local(data):
    global local_data
    local_data = data.copy()
    print('saved local data', local_data)


@socketio.on("get_data_local")
def handle_get_data_local():
    data = local_data
    emit('contract_get_data', {'data':data})


