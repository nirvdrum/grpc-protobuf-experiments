#!/usr/bin/env python

import helpers
helpers.compile_protos()

from gen.protobuf.simple_pb2 import Recursive

datum = Recursive()

for _ in range(10):
    for _ in range(1_000_000):
        Recursive(data=[datum])
    print("Memory usage {:,} KB".format(helpers.rss_in_kb()))
