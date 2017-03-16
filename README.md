# Logger: zmq->ws->elm

-----

A set of tools to:

    - sub to zmq pub and forward to websocket
    - allows for messages to go to and from frontend


## Anatomoy:
    backend:
        -ws_client.py: zmq->ws
    utils:
        -client.py: zmq->console 
    frontend:
        - elm app to show and filter logs

## Todo:

    - [ ] how to server web-app
    - [ ] consider moving to aihttp?

