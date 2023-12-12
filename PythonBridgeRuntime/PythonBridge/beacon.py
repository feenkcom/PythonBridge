import functools
import time
import inspect
from typing import Any

def beacon(message):
    def decorator_beacon(func):
        @functools.wraps(func)
        def wrapper_beacon(*args, **kwargs):
            beacon = Beacon(message)
            beacon.file = inspect.getsourcefile(func)
            [_, beacon.line] = inspect.getsourcelines(func)
            beacon.set_start()
            value = func(*args, **kwargs)
            beacon.set_end()
            return value
        return wrapper_beacon
    return decorator_beacon 

class Beacon:
    def __init__(self, message) -> None:
        self.message = message
        self.file = ''
        self.line = 0
        self.start = 0
        self.end = 0
        self.children = [] # not computed until requested

    def set_start(self):
        self.start = time.perf_counter_ns()

    def set_end(self):
        self.end = time.perf_counter_ns()
        global beacons
        beacons.add_beacon(self)
        
    def duration(self):
        return self.end-self.start


class BeaconGroup:
    def __init__(self) -> None:
        self.beacons = []

    def get_beacons(self):
        return sorted(self.beacons, key=lambda each: each.start)
    
    def get_beacon_tree(self):
        b = self.get_beacons()
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

    def add_beacon(self, beacon):
        self.beacons.append(beacon)

    def gtViewBeacons(self, aBuilder):
        return aBuilder.columnedList()\
            .title("Beacons")\
            .priority(1)\
            .items(lambda: self.get_beacons())\
            .column("Message", lambda each: each.message)\
            .column("Start", lambda each: each.start)\
            .column("End", lambda each: each.end)
    
    def gtViewBeaconsTree(self, aBuilder):
        return aBuilder.columnedTree()\
            .title("Tree")\
            .priority(2)\
            .items(lambda: self.get_beacon_tree())\
            .children(lambda each: each.children)\
            .column("Message", lambda each: each.message)\
            .column("Duration", lambda each: each.end - each.start)

def reset_beacons():
    global beacons
    beacons = BeaconGroup()

def get_beacons():
    global beacons
    return beacons