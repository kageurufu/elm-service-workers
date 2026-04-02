import Elm from "./build/worker.elm.js";

const app = Elm.Worker.init({ type: "webWorker" });
const ports = []; // For broadcasting

self.addEventListener("connect", function (event) {
  const port = event.ports[0];
  ports.push(port);

  port.addEventListener("message", (event) => {
    app.ports.onMessage.send({ client: port, data: event.data });
  });

  port.start();
});

app.ports.sendMessage.subscribe((data) => {
  console.log("Response from shared worker", data);

  data.client.postMessage(data.data);
});

app.ports.broadcast.subscribe((data) => {
  for (const port of ports) {
    port.postMessage(data);
  }
});
