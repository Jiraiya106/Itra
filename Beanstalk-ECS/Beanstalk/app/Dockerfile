FROM mhart/alpine-node:7.4.0

WORKDIR /srv
ADD . .
#RUN npm init
RUN npm install express

EXPOSE 3000
CMD ["node", "server.js"]