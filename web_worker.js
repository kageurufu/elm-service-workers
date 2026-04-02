import Elm from "./build/worker.elm.js";

const app = Elm.Worker.init({ type: "webWorker" });

self.addEventListener("message", (event) => {
  console.log("Port onMessage to web worker backend", event.data);
  app.ports.onMessage.send({ client: null, data: event.data });
});

app.ports.sendMessage.subscribe((data) => {
  console.log("Response from web worker", data);
  self.postMessage(data.data);
});

app.ports.broadcast.subscribe((data) => {
  self.postMessage(data);
});
