"""
Simple zmq client that prints to console
"""
import sys
import zmq

port = "5560"
# Socket to talk to server
context = zmq.Context()
socket = context.socket(zmq.SUB)
socket.connect ("tcp://localhost:%s" % port)
try:
    topicfilter = str(sys.argv[1])
    socket.setsockopt_string(zmq.SUBSCRIBE, topicfilter)
except:
    socket.setsockopt_string(zmq.SUBSCRIBE, "")
while True:
    # string = socket.recv_string()
    # messagedata = string.split()
    a = socket.recv_multipart()
    print(a)

