from uuid import uuid1
from .bridge_globals import bridge_globals

def ensure_global_registry():
    if not hasattr(bridge_globals(), 'obj_registry'):
        bridge_globals()['obj_registry'] = Registry()

def registry():
    return bridge_globals()['obj_registry']

class Registry():

    def __init__(self):
        self.idToObjMap = {}
        self.objToIdMap = {}

    def hasId(self, anId):
        return anId in self.idToObjMap

    def createNewObjId(self):
        return uuid1().hex
    
    def register(self, obj):
        if obj is None:
            return 0
        if id(obj) in self.objToIdMap:
            return self.objToIdMap[id(obj)]
        else:
            return self._register(obj, self.createNewObjId())
    
    def register_with_id(self, obj, newObjId):
        if obj is None:
            return RegisterForbiddenObject(obj)
        if id(obj) in self.objToIdMap:
            objId = self.objToIdMap[id(obj)]
            if objId == newObjId:
                return newObjId
            else:
                raise RegisterWithDifferentIdError(obj, newObjId)
        else:
            return self._register(obj, newObjId)

    def resolve(self, objId):
        if objId in self.idToObjMap:
            return self.idToObjMap[objId]
        else:
            raise ResolveUnknownObject(objId)

    def _register(self, obj, newObjId):
        self.idToObjMap[newObjId] = obj
        self.objToIdMap[id(obj)] = newObjId
        return newObjId

    def clean(self, objId):
        obj = self.idToObjMap[objId]
        del self.idToObjMap[objId]
        del self.objToIdMap[id(obj)]

    def isProxy(self, anObject):
        is_proxy = False

        if isinstance(anObject, dict):
            if len(anObject.keys()) == 2 and ('__pyclass__' in anObject) and ('__pyid__' in anObject):
                is_proxy = True

        return is_proxy

    def proxy(self, obj):
        if obj is None:
            return obj
        return {
            '__pyclass__': type(obj).__name__,
            '__pyid__': self.register(obj)
            }

class RegistryError(Exception):
    pass

class RegisterWithDifferentIdError(RegistryError):
    def __init__(self, obj, newId):
        RegistryError.__init__(self,"Attempting to register object {0} with ID {1} with different ID {2}.".format(type(obj).__name__, registry().register(obj), newId))

class ResolveUnknownObject(RegistryError):
    def __init__(self, objId):
        RegistryError.__init__(self,"Attempting to resolve unknown object with id {0}.".format(objId))

class RegisterForbiddenObject(RegistryError):
    def __init__(self, obj):
        RegistryError.__init__(self,"Attempting to register forbidden object of type {0}.".format(type(obj).__name__))

ensure_global_registry()
