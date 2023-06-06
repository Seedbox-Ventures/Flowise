# Build local monorepo image
# docker build --no-cache -t  flowise .

# Run image
# docker run -d -p 3000:3000 flowise

FROM --platform=linux/amd64 node:18-alpine
RUN apk add --update libc6-compat
RUN apk add --no-cache python3 make g++

WORKDIR /usr/src/packages

# Copy root package.json and lockfile
COPY package.json ./
COPY yarn.lock ./

# Copy components package.json
COPY packages/components/package.json ./packages/components/package.json

# Copy ui package.json
COPY packages/ui/package.json ./packages/ui/package.json

# Copy server package.json
COPY packages/server/package.json ./packages/server/package.json

RUN export NODE_OPTIONS="--max-old-space-size=8192" # FF: added memory bump for Node, remember to bump the Docker allocated memory!

RUN yarn install --network-timeout 100000 # FF: added network timeout

# Copy app source
COPY . .

RUN yarn build

EXPOSE 3000

CMD [ "yarn", "start" ]
