import msgpack
import socket
import _thread
import threading
import time
import sys

from .stoppable_thread import StoppableThread
from .msgpack_serializer import MsgPackSerializer
from .msgpack_serializer import addMapping as msgpack_serializer_addMapping
from .bridge_utils import random_str
from .bridge_utils import log_msg

# Messages supported by this sockets must be Dictionaries. This is because we use special key __sync to know if it is 
# a synchronized message or not. If it is we hook a semaphore to that id under the __sync key and after we receive the 
# value we store there the return message and signal the semaphore.
class MsgPackSocketPlatform:

    def __init__(self, port):
        self.port = port
        self.server = None
        self.connection = None
        self.serializer = MsgPackSerializer()
        self.unpacker = msgpack.Unpacker(raw=False)
        self.packer = msgpack.Packer(use_bin_type=True)
        self.sync_table = {}
        self.async_handlers = {}
    
    def addMapping(self, key_type, mapping_function):
        msgpack_serializer_addMapping(key_type, mapping_function)

    def set_handler(self, msg_type, async_handler):
        self.async_handlers[msg_type] = async_handler

    def prim_handle(self):
        try:
            log_msg("HANDLER (MsgPackSocketPlatform): loop func")
            data = self.getConnection().recv(2048)
            if len(data) == 0:
                log_msg("HANDLER (MsgPackSocketPlatform): received zero bytes, done")
                self.connection.close()
                self.connection = None
            else:
                self.unpacker.feed(data)
                for msg in self.unpacker:
                    log_msg("HANDLER (MsgPackSocketPlatform): prim handle message")
                    self.prim_handle_msg(msg)
        except OSError:
            log_msg("HANDLER (MsgPackSocketPlatform): OSError " + str(err))
            self.stop()
            sys.exit()
            exit(-1)
        except Exception as err:
            log_msg("HANDLER (MsgPackSocketPlatform): ERROR " + str(err))

    def setup_func(self):
        self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server.bind(('localhost', self.port))
        self.server.listen()
        
    def getConnection(self):
        if (self.connection == None):
            self.connection, addr = self.server.accept()
        return self.connection

    def stop(self):
        if self.thread is not None:
            self.thread.stop()
        if self.server is not None:
            self.server.close()
            self.server = None

    def send_answer(self, msg, answer):
        if answer['type'] != msg['type']:
            raise Exception('Type mismatch')
        answer['__sync'] = msg['__sync']
        self.send_async_message(answer)
    
    def is_running(self):
        return self.server != None
    
    def prim_handle_msg(self, raw_msg):
        msg = raw_msg
        msg_type = msg['type'] 
        if msg_type in self.async_handlers:
            self.async_handlers[msg['type']](msg)
        elif is_sync_msg(msg):
            sync_id = message_sync_id(msg)
            semaphore = self.sync_table[sync_id]
            self.sync_table[sync_id] = msg
            semaphore.release()
        else:
            log_msg("Error! Msg couldnt be handled")
            raise Exception('Message couldn''t be handled')
    
    def start(self):
        self.thread = StoppableThread(
            loop_func= self.prim_handle,
            setup_func= self.setup_func)
        self.thread.start()
        time.sleep(.1)

    def send_async_message(self, msg):
        self.getConnection().send(self.packer.pack(msg))
    
    def send_sync_message(self, msg):
        sync_id = mark_message_as_sync(msg)
        semaphore = threading.Semaphore(value=0)
        self.sync_table[sync_id] = semaphore
        self.send_async_message(msg)
        semaphore.acquire()
        ans = self.sync_table[sync_id]
        del self.sync_table[sync_id]
        return ans

def is_sync_msg(msg):
    return '__sync' in msg
    
def message_sync_id(msg):
    return msg['__sync']
    
def mark_message_as_sync(msg):
    sync_id = random_str()
    msg['__sync'] = sync_id
    return sync_id

def build_service(port, pharo_port, feed_callback):
    service = MsgPackSocketPlatform(port)
    service.set_handler('ENQUEUE',feed_callback)
    service.set_handler('IS_ALIVE', lambda msg: service.send_answer(msg, {'type': 'IS_ALIVE'}))
    return service
