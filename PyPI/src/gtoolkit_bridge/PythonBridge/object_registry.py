from .bridge_globals import bridge_globals

def ensure_global_registry():
    if not hasattr(bridge_globals(), 'obj_registry'):
        bridge_globals()['obj_registry'] = Registry()

def registry():
    return bridge_globals()['obj_registry']

class Registry():

    def __init__(self):
        self.idToRefCount = {}
        self.idToObjMap = {}

    def hasId(self, anId):
        return anId in self.idToObjMap
    
    def register(self, obj):
        if hex(id(obj)) in self.idToObjMap:
            self.idToRefCount[id(obj)] += 1
            return hex(id(obj))
        else:
            return self._register(obj, hex(id(obj)))

    def resolve(self, objId):
        if objId in self.idToObjMap:
            return self.idToObjMap[objId]
        else:
            raise ResolveUnknownObject(objId)

    def _register(self, obj, newObjId):
        self.idToRefCount[id(obj)] = 1
        self.idToObjMap[newObjId] = obj
        return newObjId

    def clean(self, objId):
        obj = self.idToObjMap[objId]
        self.idToRefCount[id(obj)] -= 1
        if self.idToRefCount[id(obj)] == 0:
            del self.idToRefCount[id(obj)]
            del self.idToObjMap[objId]

    def isProxy(self, anObject):
        is_proxy = False

        if isinstance(anObject, dict):
            if len(anObject.keys()) == 2 and ('__pyclass__' in anObject) and ('__pyid__' in anObject):
                is_proxy = True

        return is_proxy

    def proxy(self, obj):
        return {
            '__pyclass__': self.qualifiedNameOf(type(obj)),
            '__pyid__': self.register(obj),
            '__superclasses__': self.superclassesOf(obj)
            }
    
    def superclassesOf(self, obj):
        c = type(obj).__base__
        supers = []
        while c is not None:
            supers.append(self.qualifiedNameOf(c))
            c = c.__base__
        return supers

    def qualifiedNameOf(self, type):
        if type.__module__ is None or type.__module__ == 'builtins':
           return type.__name__
        else:
           return type.__module__ + '.' + type.__name__


class RegistryError(Exception):
    pass

class ResolveUnknownObject(RegistryError):
    def __init__(self, objId):
        RegistryError.__init__(self,"Attempting to resolve unknown object with id {0}.".format(objId))

class RegisterForbiddenObject(RegistryError):
    def __init__(self, obj):
        RegistryError.__init__(self,"Attempting to register forbidden object of type {0}.".format(type(obj).__name__))

ensure_global_registry()
