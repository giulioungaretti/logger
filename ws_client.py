"""
Simple client that prints to console
"""
import asyncio
import json
import logging
import sys

import zmq
import zmq.asyncio
import websockets

context = zmq.asyncio.Context()
loop = zmq.asyncio.ZMQEventLoop()
asyncio.set_event_loop(loop)
port = "5560"
socket = context.socket(zmq.SUB)
socket.connect("tcp://localhost:%s" % port)

try:
    topicfilter = str(sys.argv[1])
    socket.setsockopt_string(zmq.SUBSCRIBE, topicfilter)
except:
    socket.setsockopt_string(zmq.SUBSCRIBE, "")


p_log = logging.getLogger("producer")
p_log.setLevel(logging.DEBUG)
a = logging.StreamHandler()
fmt = logging.Formatter('%(name)s-%(levelname)s : %(message)s')
a.setFormatter(fmt)
p_log.addHandler(a)


async def producer(sock):
    msg = await sock.recv_json()
    p_log.debug(msg)
    # just get the message
    return msg

c_log = logging.getLogger("consumer")
c_log.setLevel(logging.DEBUG)
b = logging.StreamHandler()
fmt = logging.Formatter('%(name)s-%(levelname)s : %(message)s')
b.setFormatter(fmt)
c_log.addHandler(b)


async def consumer(msg):
    # do fake work
    c_log.debug(msg)
    return msg


async def handler(websocket, path):
    print(path)
    while True:
        listener_task = asyncio.ensure_future(websocket.recv())
        producer_task = asyncio.ensure_future(producer(socket))
        done, pending = await asyncio.wait(
            [listener_task, producer_task],
            return_when=asyncio.FIRST_COMPLETED)

        if listener_task in done:
            message = listener_task.result()
            await consumer(message)
        else:
            listener_task.cancel()

        if producer_task in done:
            message = producer_task.result()
            await websocket.send(json.dumps(message))
        else:
            producer_task.cancel()

start_server = websockets.serve(handler, '127.0.0.1', 5678)
asyncio.get_event_loop().run_until_complete(start_server)

asyncio.get_event_loop().run_forever()
