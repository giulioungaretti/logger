import zmq

def main():

    try:
        context = zmq.Context(1)
        # Socket facing clients
        frontend = context.socket(zmq.XSUB)
        frontend.bind("tcp://*:8888")

        # Socket facing services
        backend = context.socket(zmq.XPUB)
        backend.bind("tcp://*:5560")

        zmq.proxy(frontend, backend)
    except Exception as e:
        print(e)
        print("bringing down zmq device")
    finally:
        frontend.close()
        backend.close()
        context.term()

if __name__ == "__main__":
    main()
