// Logika aplikacji wydzielona z serwera, żeby dało się ją przetestować bez uruchamiania HTTP.
const os = require("os");

const VERSION = "3";

function handle(url) {
  if (url === "/health") {
    return { status: 200, type: "text/plain", body: "OK" };
  }
  return {
    status: 200,
    type: "text/html; charset=utf-8",
    body: `<h1>Version ${VERSION}</h1><p>Serwer: ${os.hostname()}</p>`,
  };
}

module.exports = { handle, VERSION };