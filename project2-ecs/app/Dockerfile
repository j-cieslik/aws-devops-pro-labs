# Recipe for the container image.

# 1. Start from an official image that already has Node.js 20 installed
#    (pulled from Amazon ECR Public to avoid Docker Hub rate limits).
FROM public.ecr.aws/docker/library/node:24-alpine

# 2. Work inside /app in the container.
WORKDIR /app

# 3. Copy only what the app needs to run (no tests).
COPY app.js server.js ./

# 4. Do not run as root inside the container.
USER node

# 5. Document the port and define how the container starts.
EXPOSE 3000
CMD ["node", "server.js"]
