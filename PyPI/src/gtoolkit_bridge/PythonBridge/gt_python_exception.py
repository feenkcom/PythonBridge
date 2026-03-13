import sys
from dataclasses import dataclass
from types import TracebackType


@dataclass
class GtPythonFrame:
    function: str
    filename: str
    lineno: int
    locals: dict


class GtPythonException:
    def __init__(self, exc_type, exc_value, exc_tb: TracebackType):
        self.exc_type = exc_type
        self.exc_value = exc_value
        self.exc_tb = exc_tb
        self._frames = self._extract_frames()

    def _safe_locals(self, raw_locals):
        result = {}
        for name, value in raw_locals.items():
            try:
                value_repr = repr(value)
            except Exception:
                value_repr = '<repr failed>'
            result[name] = {
                'type': type(value).__name__,
                'repr': value_repr,
            }
        return result

    def _extract_frames(self):
        frames = []
        tb = self.exc_tb
        while tb:
            frame = tb.tb_frame
            frames.append(
                GtPythonFrame(
                    function=frame.f_code.co_name,
                    filename=frame.f_code.co_filename,
                    lineno=tb.tb_lineno,
                    locals=self._safe_locals(frame.f_locals),
                )
            )
            tb = tb.tb_next
        return frames

    def as_dict(self):
        return {
            'exception_type': self.exc_type.__name__,
            'exception_message': str(self.exc_value),
            'frames': [
                {
                    'function': each.function,
                    'filename': each.filename,
                    'lineno': each.lineno,
                    'locals': each.locals,
                }
                for each in self._frames
            ],
        }
    
