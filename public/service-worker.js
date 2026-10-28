const DB_NAME = "medical-library-share";
const DB_VERSION = 1;
const STORE_NAME = "files";

self.addEventListener("install", event => event.waitUntil(self.skipWaiting()));
self.addEventListener("activate", event => event.waitUntil(self.clients.claim()));

function openShareDb() {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(DB_NAME, DB_VERSION);
    request.onupgradeneeded = () => {
      if (!request.result.objectStoreNames.contains(STORE_NAME)) {
        request.result.createObjectStore(STORE_NAME, { keyPath: "id", autoIncrement: true });
      }
    };
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
  });
}

self.addEventListener("fetch", event => {
  const request = event.request;
  const url = new URL(request.url);
  if (request.method !== "POST" || url.pathname !== "/share-target") return;

  event.respondWith((async () => {
    const form = await request.formData();
    const files = form.getAll("files").filter(value => value instanceof File && value.size > 0);
    if (!files.length) return Response.redirect(new URL("/?share=empty", self.location.origin), 303);

    const db = await openShareDb();
    await new Promise((resolve, reject) => {
      const tx = db.transaction(STORE_NAME, "readwrite");
      const store = tx.objectStore(STORE_NAME);
      for (const file of files.slice(0, 12)) store.add({ file, savedAt: Date.now() });
      tx.oncomplete = resolve;
      tx.onerror = () => reject(tx.error);
      tx.onabort = () => reject(tx.error);
    });
    db.close();
    return Response.redirect(new URL("/?shared=1", self.location.origin), 303);
  })());
});
