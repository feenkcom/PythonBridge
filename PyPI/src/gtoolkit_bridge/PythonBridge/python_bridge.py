import argparse
import threading
import sys

from .bridge_globals import bridge_globals
from .object_registry import registry
from .bridge_utils import log_msg
from .bridge_hooks import notify, notify_observer, notify_error
from .bridge_hooks import serialize, deserialize, observer


def pbbreak():
    print("Breaking now")
    breakpoint()
    print("Continuing")


class EvalCommand:
    statements = ""
    bindings = {}
    commandId = 0

    def __init__(self, commandId, statements, bindings):
        self.statements = statements
        self.commandId = commandId
        self.bindings = bindings

    def execute_using_env(self, env):
        try:
            env.update(self.bindings)
            exec(self.statements, env)
        except Exception as err:
            self.perform_proceed_action(notify_error(err, self))

    def perform_proceed_action(self, actionDict):
        actionSymbol = actionDict['action']
        if actionSymbol == "IGNORE":
            pass
        if actionSymbol == "DROP_QUEUE":
            bridge_globals()['cmd_list'].drop_queue()
        if actionSymbol == "REPLACE_COMMAND":
            commandDict = actionDict["command"]
            bridge_globals()['cmd_list'].push_command_at_first(EvalCommand(
                commandDict["commandId"],
                commandDict["statements"],
                commandDict["bindings"]))

    def command_id(self):
        return self.commandId


def log_stderr_flush(msg):
    print(str(msg), file=sys.stderr, flush=True)


class Logger:
    def log(self, msg):
        log_stderr_flush(msg)


class NoLogger:
    def log(self, msg):
        pass


# This List is thought to be multi-producer and single-consumer. For optimal results wait for push_command return
# value to push another command that depends on the previous one.
class PythonCommandList:
    currentCommandIndex = 0
    commandList = []
    listLock = threading.Lock()
    consumeSemaphore = threading.Semaphore(value=0)

    # This method locks the thread until the command has been succesfully appended to the list. Even though that it
    # has a lock inside, we do not expect long waiting time.
    def push_command(self, aCommand):
        self.listLock.acquire()
        self.commandList.append(aCommand)
        commandIndex = len(self.commandList) - 1
        self.listLock.release()
        self.consumeSemaphore.release()
        return commandIndex

    def push_command_at_first(self, aCommand):
        self.listLock.acquire()
        self.commandList.insert(self.currentCommandIndex, aCommand)
        self.listLock.release()
        self.consumeSemaphore.release()
        return self.currentCommandIndex

    def drop_queue(self):
        self.listLock.acquire()
        self.consumeSemaphore = threading.Semaphore(value=0)
        self.currentCommandIndex = len(self.commandList)
        self.listLock.release()

    def consume_command(self):
        repeatMonitorFlag = True
        while repeatMonitorFlag:
            self.consumeSemaphore.acquire()
            self.listLock.acquire()
            repeatMonitorFlag = False
            if self.currentCommandIndex >= len(self.commandList):
                repeatMonitorFlag = True
                self.listLock.release()
        command = self.commandList[self.currentCommandIndex]
        self.currentCommandIndex += 1
        self.listLock.release()
        return command

    def get_current_command(self):
        if self.currentCommandIndex == 0:
            return None
        self.listLock.acquire()
        command = self.commandList[self.currentCommandIndex - 1]
        self.listLock.release()
        return command

    def get_command_list(self):
        self.listLock.acquire()
        listCopy = self.commandList.copy()
        self.listLock.release()
        return listCopy


def deserialize(text):
    result = bridge_globals()['msg_service'].serializer.deserialize(text)
    log_msg("DESERIALISE (bridge): " + str(result))
    if registry().isProxy(result):
        result = registry().resolve(result['__pyid__'])
    return result


def enqueue_command(data):
    bridge_globals()['cmd_list'].push_command(EvalCommand(
        data["commandId"],
        data["statements"],
        {k: deserialize(v) for k, v in data["bindings"].items()}))


def parse_bridge_cmd_line_args():
    ap = argparse.ArgumentParser()
    ap.add_argument("-p", "--port", required=False,
                    help="port to be used for receiving instructions")
    ap.add_argument("-o", "--pharo", required=True,
                    help="port to be used for sending notifications back to pharo")
    ap.add_argument("-m", "--method", required=False,
                    help="identifier for communication protocol strategy http or msgpack")
    ap.add_argument("--log", required=False, const=True, nargs="?",
                    help="enable logging")
    return vars(ap.parse_args())


def bridge_args():
    return {'port': 9099, 'pharo': 0, 'method': 'msgpack', 'log': True}


def setup_bridge(args):
    bridge_globals()['pharo_port'] = args["pharo"]

    if args["log"]:
        bridge_globals()['logger'] = Logger()
    else:
        bridge_globals()['logger'] = NoLogger()

    bridge_globals()['python_port'] = args["port"]

    msg_service = None
    if args["port"] is None:
        args["port"] = '0'
    if args["method"] is None:
        args["method"] = 'http'
    if args["method"] == 'http':
        from .flask_platform import build_service
        msg_service = build_service(int(args["port"]), int(args["pharo"]), enqueue_command)
    elif args["method"] == 'msgpack':
        from .msgpack_socket_platform import build_service
        msg_service = build_service(int(args["port"]), int(args["pharo"]), enqueue_command)
    else:
        raise Exception("Invalid communication strategy.")
    bridge_globals()['msg_service'] = msg_service


def run_bridge():
    bridge_globals()['msg_service'].start()

    log_stderr_flush("PythonBridge ready")

    bridge_globals()['cmd_list'] = PythonCommandList()
    globalCommandList = bridge_globals()['cmd_list']
    env = dict(globals())

    log_msg("PYTHON: Start consuming commands")
    while True:
        command = globalCommandList.consume_command()
        log_msg("PYTHON: Executing command " + command.command_id())
        log_msg("PYTHON: bindings: " + str(command.bindings))
        log_msg("PYTHON: " + command.statements)
        command.execute_using_env(env)
        log_msg("PYTHON: Finished command execution")


def run_bridge_default():
    log_stderr_flush("PythonBridge starting")

    args = bridge_args()

    log_stderr_flush(args)

    setup_bridge(args)

    run_bridge()


def run_bridge_main():
    log_stderr_flush("PythonBridge starting")

    args = parse_bridge_cmd_line_args()

    log_stderr_flush(args)

    setup_bridge(args)

    run_bridge()


if __name__ == "__main__":
    run_bridge_main()
