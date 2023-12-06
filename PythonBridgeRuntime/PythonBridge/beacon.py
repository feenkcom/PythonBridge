import functools
import time
from typing import Any

def beacon(message):
    def decorator_beacon(func):
        @functools.wraps(func)
        def wrapper_beacon(*args, **kwargs):
            beacon = Beacon()
            beacon.message = message
            beacon.start = time.perf_counter_ns()
            value = func(*args, **kwargs)
            beacon.end  = time.perf_counter_ns()
            global beacons
            beacons.add_beacon(beacon)
            return value
        return wrapper_beacon
    return decorator_beacon 

class Beacon:
    def __init__(self) -> None:
        self.message = 'Foobar'
        self.start = 0
        self.end = 0


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
        children = []
        while index < len(list) and list[index].start < root.end:
            [newindex, kids] = self.compute_tree(index, list)
            children.append(kids)
            index = newindex
        return [index, [ root, children ]]

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
            .children(lambda each: each[1])\
            .column("Message", lambda each: each[0].message)\
            .column("Duration", lambda each: each[0].end - each[0].start)

def reset_beacons():
    global beacons
    beacons = BeaconGroup()

def get_beacons():
    global beacons
    return beacons