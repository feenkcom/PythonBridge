import functools
import time
import inspect
from typing import Any

def methodevent(message):
    def decorate(func):
        @functools.wraps(func)
        def wrapped_function(*args, **kwargs):
            signal = MethodStartSignal(message)
            signal.file = inspect.getsourcefile(func)
            [_, signal.line] = inspect.getsourcelines(func)
            try:
                value = func(*args, **kwargs)
                return value
            finally:
                MethodEndSignal(message)
        return wrapped_function
    return decorate

def argmethodevent(message):
    def decorate(func):
        @functools.wraps(func)
        def wrapped_function(*args, **kwargs):
            signal = ArgumentMethodStartSignal(message, kwargs)
            signal.file = inspect.getsourcefile(func)
            [_, signal.line] = inspect.getsourcelines(func)
            try:
                value = func(*args, **kwargs)
                return value
            finally:
                MethodEndSignal(message)
        return wrapped_function
    return decorate

class TelemetrySignal:
    def __init__(self, message) -> None:
        self.message = message
        self.timestamp = time.perf_counter_ns()
        cf = inspect.stack()[1]
        self.file = cf.filename
        self.line = cf.lineno
        global signals
        signals.add_signal(self)

    def isStartSignal(self):
        return False
    
    def isEndSignal(self):
        return False
    
    def gtViewSignalTree(self, aBuilder):
        return aBuilder.columnedTree()\
            .title("Tree")\
            .priority(2)\
            .items(lambda: [self])\
            .children(lambda each: each.children)\
            .column("Message", lambda each: each.message)\
            .column("Duration", lambda each: each.duration())

class TelemetryEvent:
    def __init__(self, message):
        self.signals = []
        self.children = []
        self.message = message

    def duration(self):
        if len(self.signals) < 2:
            return 0
        else:
            return self.signals[-1].timestamp - self.signals[0].timestamp

class MethodStartSignal(TelemetrySignal):
    def isStartSignal(self):
        return True
    
    def isEndSignal(self):
        return False

class MethodEndSignal(TelemetrySignal):
    def isStartSignal(self):
        return False
    
    def isEndSignal(self):
        return True

class ArgumentMethodStartSignal(MethodStartSignal):
    def __init__(self, message, args):
        super().__init__(message)
        self.args = args.copy()

class TelemetrySignalGroup:
    def __init__(self) -> None:
        self.signals = []

    def get_signals(self):
        return sorted(self.signals, key=lambda each: each.timestamp)
    
    def get_event_tree(self):
        b = self.get_signals()
        value = []
        index = 0
        while index < len(b):
            [index, tree] = self.compute_tree(index, b, 0)
            value.append(tree)
        return value
    
    def compute_tree(self, index, list, depth):
        print(f"Depth: {depth}:{index}/{len(list)}")
        if index >= len(list):
            return [index, []]
        if not list[index].isStartSignal:
            return [index+1, list[index]]    # leaf signals
        root = TelemetryEvent(list[index].message)
        root.signals.append(list[index])
        index = index + 1
        root.children = []
        while index < len(list) and not list[index].isEndSignal():
            [newindex, kids] = self.compute_tree(index, list, depth+1)
            print(f"*{newindex}*")
            root.children.append(kids)
            index = newindex
        if index < len(list):
            root.signals.append(list[index])
            index = index + 1
        return [index, root]

    def add_signal(self, signal):
        self.signals.append(signal)

    def gtViewSignals(self, aBuilder):
        return aBuilder.columnedList()\
            .title("Signals")\
            .priority(1)\
            .items(lambda: self.get_signals())\
            .column("Signal Class", lambda each:f"{each.__class__.__name__}")\
            .column("Message", lambda each: each.message)\
            .column("Timestamp", lambda each: each.timestamp)
    
    def gtViewSignalTree(self, aBuilder):
        return aBuilder.columnedTree()\
            .title("Tree")\
            .priority(2)\
            .items(lambda: self.get_event_tree())\
            .children(lambda each: each.children)\
            .column("Message", lambda each: each.message)\
            .column("Duration", lambda each: each.duration())

def reset_signals():
    global signals
    signals = TelemetrySignalGroup()

def get_signals():
    global signals
    return signals