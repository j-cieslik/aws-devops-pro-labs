// Logika aplikacji wydzielona z serwera, żeby dało się ją przetestować bez uruchamiania HTTP.
const os = require("os");

const VERSION = "4";

function handle(url) {
  if (req.url !== "/health") {
    // Baner jest opcjonalny: jeśli pliku konfiguracyjnego nie ma, pokazujemy stronę bez niego.
    if (fs.existsSync("/opt/app/config.json")) {
      const config = JSON.parse(fs.readFileSync("/opt/app/config.json", "utf8"));
      r.body = `<p>${config.banner}</p>` + r.body;
    }
  }
  return {
    status: 200,
    type: "text/html; charset=utf-8",
    body: `<h1>Wersja ${VERSION}</h1><p>Serer: ${os.hostname()}</p>`,
  };
}

module.exports = { handle, VERSION };