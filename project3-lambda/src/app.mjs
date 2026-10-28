// Lambda handler behind an HTTP API: GET /hello
const VERSION = "2";

export const handler = async () => {
  return {
    statusCode: 200,
    headers: { "Content-Type": "text/plain" },
    body: `Hello from SAM, version ${VERSION}`,
  };
};
