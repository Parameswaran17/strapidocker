FROM node:18-alpine

WORKDIR /usr/src/app

RUN npm install -g strapi@latest

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 1337

CMD ["npm", "run", "start"]
