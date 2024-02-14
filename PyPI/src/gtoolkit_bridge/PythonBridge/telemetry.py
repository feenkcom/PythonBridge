import bisect
import functools
import time
import inspect
from typing import Any
from abc import ABC, abstractmethod
from gtoolkit_bridge import gtView

def methodevent(message):
    def decorate(func):
        @functools.wraps(func)
        def wrapped_function(*args, **kwargs):
            if 'signals' not in globals():
                return func(*args, **kwargs)
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
            if 'signals' not in globals():
                return func(*args, **kwargs)           
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

class Telemetry(ABC):
    def __init__(self, message):
        super().__init__
        self.message = message

    def children(self):
        return []

    @abstractmethod
    def timestamp(self):
        pass

    @abstractmethod
    def duration(self):
        pass

class TelemetrySignal(Telemetry):
    def __init__(self, message) -> None:
        super().__init__(message)
        self._timestamp = time.perf_counter_ns()
        cf = inspect.stack()[1]
        self.file = cf.filename
        self.line = cf.lineno

        if 'signals' in globals():
            global signals
            signals.add_signal(self)

    def timestamp(self):
        return self._timestamp

    def duration(self):
        return 0

    def isStartSignal(self):
        return False
    
    def isEndSignal(self):
        return False
    
    @gtView
    def gtViewSignalTree(self, aBuilder):
        return aBuilder.columnedTree()\
            .title("Tree")\
            .priority(2)\
            .items(lambda: [self])\
            .children(lambda each: each.children())\
            .column("Message", lambda each: each.message)\
            .column("Duration", lambda each: each.duration())

class TelemetryEvent(Telemetry):
    def __init__(self, message):
        super().__init__(message)
        self._children = []
        self.startSignal = None
        self.endSignal = None

    def children(self):
        return self._children

    def addChild(self, child):
        bisect.insort(self._children, child, key=lambda x:x.timestamp())

    def timestamp(self):
        return self.startSignal.timestamp()

    def duration(self):
        return self.endSignal.timestamp() - self.startSignal.timestamp()
    
    @gtView
    def gtViewEventTree(self, aBuilder):
        return aBuilder.columnedTree()\
            .title("Tree")\
            .priority(2)\
            .items(lambda: [ self ])\
            .children(lambda each: each.children())\
            .column("Message", lambda each: each.message)\
            .column("Duration", lambda each: each.duration())

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
        return self.signals
    
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
        if not list[index].isStartSignal():
            return [index+1, list[index]]    # leaf signals
        root = TelemetryEvent(list[index].message)
        root.startSignal = list[index]
        index = index + 1
        while index < len(list) and not list[index].isEndSignal():
            [newindex, kid] = self.compute_tree(index, list, depth+1)
            root.addChild(kid)
            index = newindex
        if index < len(list):
            root.endSignal = list[index]
            index = index + 1
        return [index, root]

    def add_signal(self, signal):
        self.signals.append(signal)

    @gtView
    def gtViewSignals(self, aBuilder):
        return aBuilder.columnedList()\
            .title("Signals")\
            .priority(1)\
            .items(lambda: self.get_signals())\
            .column("Signal Class", lambda each:f"{each.__class__.__name__}")\
            .column("Message", lambda each: each.message)\
            .column("Timestamp", lambda each: each.timestamp())
    
    @gtView
    def gtViewSignalTree(self, aBuilder):
        return aBuilder.columnedTree()\
            .title("Tree")\
            .priority(2)\
            .items(lambda: self.get_event_tree())\
            .children(lambda each: each.children())\
            .column("Message", lambda each: each.message)\
            .column("Duration", lambda each: each.duration())

def start_signals():
    reset_signals()

def reset_signals():
    global signals
    signals = TelemetrySignalGroup()

def get_signals():
    global signals
    return signals