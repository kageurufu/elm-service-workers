Elm as a Worker
===============

This is a demo of running an Elm app on the Frontend *and* as a Worker, using a unified codebase and a RPC for processing requests in the worker.

`Interop/` defines messages and encoding/decoding for the RPC

`Worker.elm` exports `main: Platform.worker` that runs as a Web Worker, Shared Worker, or Service Worker.

`Frontend.elm` exports `main : Browser.document` as a simple demo application to make requests to the worker.


Worker Differences, and working around them
===========================================

The different types of web workers each need some special handling. 
To provide a unified Elm API within the workers, all messages in and out of the Elm worker include an opaque `ClientId`. This is simply passed around as a `Json.Encode.Value` until the result is returned to the frontend.

In a Web Worker, there isn't any need to differentiate between multiple clients so the value is just null.

Shared Workers communicate over a [`MessagePort`](https://developer.mozilla.org/en-US/docs/Web/API/MessagePort). In this case, the ClientId actually holds the javascript-side `MessagePort` instance for simplicity. 

For a Service Worker, all message events include a client UUID. This UUID is passed through and used to look up the proper client to respond to on completion.


Broadcasting messages
=====================

Given both Service and Shared Workers handle multiple clients, I thought it was useful to support broadcasting messages to all active clients. Service Workers provide a nice `self.clients.matchAll()` to iterate over all active clients. Shared Workers have no such luxury, so I keep an array of opened ports. I couldn't find an easy way to determine if a port is still active, so there is currently no cleanup for the ports.
