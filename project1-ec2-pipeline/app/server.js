// Serwer HTTP na porcie 3000; całą logikę odpowiedzi trzyma app.js.
const http = require("http");
const { handle } = require("./app");

http.createServer((req, res) => {
  const r = handle(req.url);
  res.writeHead(r.status, { "Content-Type": r.type });
  res.end(r.body);
}).listen(3000);
