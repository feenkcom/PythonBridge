# gtoolkit_bridge
# Glamorous Toolkit Python Bridge

This library creates a server in Python that is accessible by Glamorous Toolkit and used to execute Python code
and get results back as proxies or values.

## Quick start

```
import gtoolkit_bridge as pb
args = pb.bridge_args()
pb.setup_bridge(args)
pb.run_bridge()
```

## All in one

```
import gtoolkit_bridge as pb
pb.run_bridge_default()
```

## Command line

```
$ python3 -m gtoolkit_bridge --port 9099 --pharo 0 --method msgpack --log
```

## Output

With logging enabled (log=True).

```
PythonBridge starting
{'port': 9099, 'pharo': 0, 'method': 'msgpack', 'log': True}
HANDLER (MsgPackSocketPlatform): loop func
PythonBridge ready
PYTHON: Start consuming commands
HANDLER (MsgPackSocketPlatform): prim handle message
HANDLER (MsgPackSocketPlatform): loop func
HANDLER (MsgPackSocketPlatform): prim handle message
DESERIALISE (bridge): pb2r9p5j02wd68kmzj1jw6zshk2
HANDLER (MsgPackSocketPlatform): loop func
PYTHON: Executing command pb2r9p5j02wd68kmzj1jw6zshk2
PYTHON: bindings: {'pharoCommandId': 'pb2r9p5j02wd68kmzj1jw6zshk2'}
PYTHON: notify(None,'pb2r9p5j02wd68kmzj1jw6zshk2')

PYTHON: Notify pb2r9p5j02wd68kmzj1jw6zshk2
PYTHON: Finished command execution
HANDLER (MsgPackSocketPlatform): prim handle message
DESERIALISE (bridge): pb2r9p5iy4fmkbyermp1kgy58qf
HANDLER (MsgPackSocketPlatform): loop func
PYTHON: Executing command pb2r9p5iy4fmkbyermp1kgy58qf
PYTHON: bindings: {'pharoCommandId': 'pb2r9p5iy4fmkbyermp1kgy58qf'}
PYTHON: import random
notify(list(map(lambda x: random.randrange(99)+1, range(1,10))), 'pb2r9p5iy4fmkbyermp1kgy58qf')
PYTHON: Notify pb2r9p5iy4fmkbyermp1kgy58qf
PYTHON: Finished command execution
```

# Info

feenk team (gt@feenk.com)

- https://gtoolkit.com
- https://feenk.com
- https://github.com/feenkcom/PythonBridge
