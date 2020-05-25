FROM node:11-alpine as builder
RUN apk add --no-cache --virtual .gyp python make g++
WORKDIR /app
ENV NODE_ENV=production
COPY package.json yarn.lock ./
RUN yarn --frozen-lockfile --non-interactive
COPY . .
RUN yarn build

# stage 2
# => Run container
FROM nginx:1.15.2-alpine
COPY nginx /etc/nginx/
# # Static build
COPY --from=builder /app/public /usr/share/nginx/html/
# # Default port exposure
EXPOSE 8080
WORKDIR /usr/share/nginx/html
# Add bash
RUN apk add --no-cache bash
HEALTHCHECK CMD [ "wget", "-q", "localhost:8080" ]
