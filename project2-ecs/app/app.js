// Application logic kept separate from the HTTP server so it can be unit tested without starting HTTP.
const os = require("os");

const VERSION = "3";

function handle(url) {
  if (url === "/health") {
    return { status: 200, type: "text/plain", body: "OK" };
  }
  return {
    status: 200,
    type: "text/html; charset=utf-8",
    body: `<h1>Project 2 - Version ${VERSION}</h1><p>Container: ${os.hostname()}</p>`,
  };
}

module.exports = { handle, VERSION };
