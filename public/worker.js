import Elm from "./build/Worker.elm.js";

const app = Elm.Worker.init({});

// Shared Worker
app.ports.receiveMessage;
app.ports.newClient;
app.ports.broadcastMessage;
app.ports.sendMessage;

const ports = [];

self.addEventListener("connect", (event) => {
  console.log("Worker :: connect", event);

  const port = event.ports[0];
  ports.push(port);

  app.ports.newClient.send( port );

  port.addEventListener("message", (event) => {
    console.log("Worker :: receiveMessage", event.data);
    app.ports.receiveMessage.send({ client: port, data: event.data });
  });

  port.start();
});

app.ports.sendMessage.subscribe((data) => {
  console.log("Worker :: sendMessage", data);
  data.client.postMessage(data.data);
});

app.ports.broadcastMessage.subscribe((data) => {
  console.log("Worker :: broadcastMessage", data);
  for (const port of ports) {
    port.postMessage(data);
  }
});
