from uuid import uuid1
from .bridge_globals import bridge_globals

def random_str():
    return uuid1().hex

def log_msg(msg):
    bridge_globals()['logger'].log(msg)
