import json_encoder
import json
import unittest
import io
from object_registry import registry

class TestJSONEncoder(unittest.TestCase):

    def setUp(self):
        self.encoder = json_encoder.JsonEncoder()
    
    def assert_encode_raw(self, obj, expected):
        self.assertEqual(self.encoder.encode(obj),expected)

    def assert_encode(self, obj, expected):
        self.assertEqual(json.loads(self.encoder.encode(obj)),expected)

    def test_encode_int(self):
        self.assert_encode_raw(3,'3')

    def test_encode_float(self):
        self.assert_encode_raw(5.5,'5.5')

    def test_add_mapping(self):
        json_encoder.addMapping(type(self), lambda obj: 'Foooo!')
        self.assert_encode(self,'Foooo!')

    def test_encode_obj(self):
        registry().register_with_id(self.encoder,'337')
        self.assert_encode(self.encoder,{'__pyclass__': "JsonEncoder", "__pyid__": '337'})