import Elm from "./build/Frontend.elm.js";
window.Elm = Elm;

function createWorker() {
  const sharedWorker = new SharedWorker("./worker.js", {
    name: "Elm.Worker",
    type: "module",
  });

  return sharedWorker;
}

function main() {
  const worker = createWorker();

  const node = document.querySelector("#app");
  const flags = { worker: true };

  const app = Elm.Frontend.init({ node, flags });
  window.app = app;

  // Wire up the shared worker
  app.ports.sendMessage.subscribe((message) => {
    console.log("Frontend :: sendMessage", message);
    worker.port.postMessage(message);
  });
  worker.port.addEventListener("message", (event) => {
    console.log("Frontend :: receiveMessage", event.data);
    app.ports.receiveMessage.send(event.data);
  });
  worker.port.start();
}

main();
