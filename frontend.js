import "./build/worker.elm.js";
import Elm from "./build/frontend.elm.js";

function startFrontend(worker) {
  const node = document.querySelector("#app");
  const flags = {
    worker:
      worker instanceof Worker
        ? "Web Worker"
        : worker instanceof SharedWorker
          ? "Shared Worker"
          : worker instanceof ServiceWorker
            ? "Service Worker"
            : null,
  };
  const app = Elm.Frontend.init({
    node,
    flags,
  });

  if (worker instanceof SharedWorker) {
    worker.port.start();

    worker.port.addEventListener("message", (event) => {
      console.log("Message to frontend: ", event.data);
      app.ports.onMessage.send(event.data);
    });

    app.ports.sendMessage.subscribe((message) => {
      console.log("Posting to shared worker:", message);
      worker.port.postMessage(message);
    });
  } else {
    if (worker instanceof ServiceWorker) {
      navigator.serviceWorker.addEventListener("message", (event) => {
        console.log("Message to frontend: ", event.data);
        app.ports.onMessage.send(event.data);
      });
    }

    // Web Workers use a single port, service workers never generate this event
    worker.addEventListener("message", (event) => {
      console.log("Message to frontend", event.data);
      app.ports.onMessage.send(event.data);
    });

    app.ports.sendMessage.subscribe((message) => {
      console.log("Posting to worker:", message);
      worker.postMessage(message);
    });
  }
}

async function registerServiceWorker() {
  if ("serviceWorker" in navigator) {
    try {
      const registration = await navigator.serviceWorker.register(
        "service_worker.js",
        {
          type: "module",
        },
      );

      if (registration.installing) {
        console.log("service worker installing");
        return registration.installing;
      } else if (registration.waiting) {
        console.log("service worker installed");
        return registration.waiting;
      } else if (registration.active) {
        console.log("service worker active");
        return registration.active;
      } else {
        console.log(registration);
      }
    } catch (error) {
      console.error(error);
    }
  }
}

async function createWebWorker() {
  const worker = new Worker("web_worker.js", {
    type: "module",
    name: "elm web worker",
  });
  return worker;
}

async function createSharedWorker() {
  const worker = new SharedWorker("shared_worker.js", {
    type: "module",
    name: "elm shared worker",
  });

  return worker;
}

async function main() {
  const worker =
    document.location.search == "?service_worker"
      ? await registerServiceWorker()
      : document.location.search == "?shared_worker"
        ? await createSharedWorker()
        : await createWebWorker();

  startFrontend(worker);
}

main();
