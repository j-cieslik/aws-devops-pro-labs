// HTTP server on port 3000; all response logic lives in app.js.
const http = require("http");
const fs = require("fs");
const { handle } = require("./app");

http.createServer((req, res) => {
  const r = handle(req.url);
  if (req.url !== "/health") {
    // The banner is optional: if the config file is missing, render the page without it.
    if (fs.existsSync("/opt/app/config.json")) {
      const config = JSON.parse(fs.readFileSync("/opt/app/config.json", "utf8"));
      r.body = `<p>${config.banner}</p>` + r.body;
    }
  }
  res.writeHead(r.status, { "Content-Type": r.type });
  res.end(r.body);
}).listen(3000);
