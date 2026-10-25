// HTTP server on port 3000; all response logic lives in app.js.
const http = require("http");
const { handle } = require("./app");

http.createServer((req, res) => {
  const r = handle(req.url);
  res.writeHead(r.status, { "Content-Type": r.type });
  res.end(r.body);
}).listen(3000);
