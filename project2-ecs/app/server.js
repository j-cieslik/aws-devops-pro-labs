// HTTP server on port 3000; all response logic lives in app.js.
const http = require("http");
const { handle } = require("./app");

http.createServer((req, res) => {
  // BUG (on purpose): every page except /health returns an error.
  if (req.url !== "/health") {
    res.writeHead(500, { "Content-Type": "text/plain" });
    return res.end("Internal error");
  }
  const r = handle(req.url);
  res.writeHead(r.status, { "Content-Type": r.type });
  res.end(r.body);
}).listen(3000);