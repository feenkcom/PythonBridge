import functools
import time
import inspect
from typing import Any

def beacon(message):
    def decorator_beacon(func):
        @functools.wraps(func)
        def wrapper_beacon(*args, **kwargs):
            signal = BeaconSignal(message)
            signal.set_start()
            signal.file = inspect.getsourcefile(func)
            [_, signal.line] = inspect.getsourcelines(func)
            value = func(*args, **kwargs)
            signal.set_end()
            return value
        return wrapper_beacon
    return decorator_beacon 

class BeaconSignal:
    def __init__(self, message) -> None:
        self.message = message
        self.file = ''
        self.line = 0
        self.start = 0
        self.end = 0
        self.children = [] # not computed until requested

    def set_start(self):
        self.start = time.perf_counter_ns()
        cf = inspect.stack()[1]
        self.file = cf.filename
        self.line = cf.lineno
        return self

    def set_end(self):
        self.end = time.perf_counter_ns()
        global signals
        signals.add_signal(self)
        
    def duration(self):
        return self.end-self.start


class BeaconSignalGroup:
    def __init__(self) -> None:
        self.signals = []

    def get_signals(self):
        return sorted(self.signals, key=lambda each: each.start)
    
    def get_signal_tree(self):
        b = self.get_signals()
        value = []
        index = 0
        while index < len(b):
            [index, tree] = self.compute_tree(index, b)
            value.append(tree)
        return value
    
    def compute_tree(self, index, list):
        if index >= len(list):
            return [index, []]
        root = list[index]
        index = index + 1
        root.children = []
        while index < len(list) and list[index].start < root.end:
            [newindex, kids] = self.compute_tree(index, list)
            root.children.append(kids)
            index = newindex
        return [index, root]

    def add_signal(self, signal):
        self.signals.append(signal)

    def gtViewSignals(self, aBuilder):
        return aBuilder.columnedList()\
            .title("Signals")\
            .priority(1)\
            .items(lambda: self.get_signals())\
            .column("Message", lambda each: each.message)\
            .column("Start", lambda each: each.start)\
            .column("End", lambda each: each.end)
    
    def gtViewSignalTree(self, aBuilder):
        return aBuilder.columnedTree()\
            .title("Tree")\
            .priority(2)\
            .items(lambda: self.get_signal_tree())\
            .children(lambda each: each.children)\
            .column("Message", lambda each: each.message)\
            .column("Duration", lambda each: each.duration())

def reset_signals():
    global signals
    signals = BeaconSignalGroup()

def get_signals():
    global signals
    return signals