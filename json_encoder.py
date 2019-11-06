import json
import io
from PythonBridge.object_registry import registry

class JsonEncoder(json.JSONEncoder):
    def __init__(self, *args, **kwargs):
        json.JSONEncoder.__init__(self, *args, **kwargs)
        self.mapper = self.default_mapper()

    def default_mapper(self):
        d = {}
        return d

    def default(self, obj):
        if type(obj) in self.mapper:
            return mapper[type(obj)](obj)
        return {
            '__pyclass__': type(obj).__name__,
            '__pyid__': registry().register(obj)
            }

class JsonSerializer:
    def serialize(self, obj):
        return json.dumps(obj, cls=JsonEncoder)

    def deserialize(self, text):
        return json.loads(text)