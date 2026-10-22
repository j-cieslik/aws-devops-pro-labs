// Serwer HTTP na porcie 3000; całą logikę odpowiedzi trzyma app.js.
const http = require("http");
const fs = require("fs");
const { handle } = require("./app");

http.createServer((req, res) => {
  const r = handle(req.url);
  if (req.url !== "/health") {
    // Baner jest opcjonalny: jeśli pliku konfiguracyjnego nie ma, pokazujemy stronę bez niego.
    if (fs.existsSync("/opt/app/config.json")) {
      const config = JSON.parse(fs.readFileSync("/opt/app/config.json", "utf8"));
      r.body = `<p>${config.banner}</p>` + r.body;
    }
  }
  res.writeHead(r.status, { "Content-Type": r.type });
  res.end(r.body);
}).listen(3000);