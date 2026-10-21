// Testy jednostkowe (wbudowany test runner Node.js: `node --test`).
const test = require("node:test");
const assert = require("node:assert");
const { handle } = require("../app");

test("/health zwraca 200 i OK", () => {
  const r = handle("/health");
  assert.strictEqual(r.status, 200);
  assert.strictEqual(r.body, "OK");
});

test("strona główna pokazuje numer wersji", () => {
  const r = handle("/");
  assert.strictEqual(r.status, 200);
  assert.match(r.body, /Wersja \d+/);
});
