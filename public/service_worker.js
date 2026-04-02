import Elm from "./build/worker.elm.js";

const app = Elm.Worker.init({ type: "serviceWorker" });

self.addEventListener("message", (event) => {
  console.log("Sending to worker port:", event.data);
  app.ports.onMessage.send({ client: event.source.id, data: event.data });
});

app.ports.sendMessage.subscribe(async (data) => {
  console.log("Received from worker:", data);
  let client = await self.clients.get(data.client);
  client.postMessage(data.data);
});

app.ports.broadcast.subscribe(async (data) => {
  for (const client of await self.clients.matchAll()) {
    client.postMessage(data);
  }
});

self.addEventListener("install", (event) => {
  self.skipWaiting();
  console.log("Service worker install", event);
});

self.addEventListener("activate", () => {
  // The actual "init" function?
  console.log("worker claiming clients");
  self.clients.claim();
});

// self.addEventListener("fetch", (event) => {
//   if (event.request.method == "WORKER") {
//     console.log("Handling worker request");
//     event.respondWith(handleFetch(event));
//   }
// });

// const pendingRequests = new Map();

// app.ports.fetchResponse.subscribe((data) => {
//   pendingRequests[data.key];
// });

// async function handleFetch(event) {
//   console.log(event);
//   app.ports.onFetch.send("request");
//   return new Response(JSON.stringify({ status: "ok" }));
// }

// console.log("service worker script reached the end");
