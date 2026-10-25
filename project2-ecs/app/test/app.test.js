// Unit tests (built-in Node.js test runner: `node --test`).
const test = require("node:test");
const assert = require("node:assert");
const { handle } = require("../app");

test("/health returns 200 and OK", () => {
  const r = handle("/health");
  assert.strictEqual(r.status, 200);
  assert.strictEqual(r.body, "OK");
});

test("home page shows the version number", () => {
  const r = handle("/");
  assert.strictEqual(r.status, 200);
  assert.match(r.body, /Version \d+/);
});
