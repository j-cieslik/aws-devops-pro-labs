// Najprostsza aplikacja webowa: strona główna pokazuje wersję i nazwę serwera,
// a /health służy load balancerowi do sprawdzania, czy aplikacja żyje.
const http = require("http");
const os = require("os");

const VERSION = "1";

http.createServer((req, res) => {
  if (req.url === "/health") {
    res.writeHead(200, { "Content-Type": "text/plain" });
    return res.end("OK");
  }
  res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
  res.end(`<h1>Wersja ${VERSION}</h1><p>Serwer: ${os.hostname()}</p>`);
}).listen(3000);
