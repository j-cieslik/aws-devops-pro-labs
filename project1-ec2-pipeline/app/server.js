// Serwer HTTP na porcie 3000; całą logikę odpowiedzi trzyma app.js.
const http = require("http");
const fs = require("fs");
const { handle } = require("./app");

http.createServer((req, res) => {
  const r = handle(req.url);
  if (req.url !== "/health") {
    try {
      // NOWA FUNKCJA: baner z pliku konfiguracyjnego.
      // BŁĄD: na serwerze nikt nie utworzył pliku config.json!
      const config = JSON.parse(fs.readFileSync("/opt/app/config.json", "utf8"));
      
      if (config != null)
      {
        r.body = `<p>${config.banner}</p>` + r.body;
      }
      else
      {
        r.body = `<p>Hello World</p>` + r.body;

      }
    } catch (err) {
      res.writeHead(500, { "Content-Type": "text/plain" });
      return res.end("Blad serwera: brak konfiguracji");
    }
  }
  res.writeHead(r.status, { "Content-Type": r.type });
  res.end(r.body);
}).listen(3000);