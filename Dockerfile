FROM node:18 as builder
# # install vue-cli vue-cli-service
# # RUN npm install -g @vue/cli
# # RUN npm install -g @vue/cli-service-global

RUN mkdir src
WORKDIR /src
COPY . /src
# ENV BROWSER_BASE_URL=http://66.42.55.52/api

# RUN yarn install
# RUN export NODE_OPTIONS=--openssl-legacy-provider && yarn run build
# RUN export NODE_OPTIONS=--openssl-legacy-provider && yarn run generate

# # ENV HOST 0.0.0.0
# # EXPOSE 3000
# # ENV NUXT_HOST=0.0.0.0
# RUN export NODE_OPTIONS=--openssl-legacy-provider
# # ENTRYPOINT export NODE_OPTIONS=--openssl-legacy-provider
# ENV NODE_OPTIONS=--openssl-legacy-provider
# CMD ["yarn", "start"]

FROM nginx:alpine as production-build
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf

# Remove default nginx index page
RUN rm -rf /usr/share/nginx/html/*


COPY --from=builder /src/dist /usr/share/nginx/html

RUN chmod -R 755 usr/share/nginx/html

EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]
