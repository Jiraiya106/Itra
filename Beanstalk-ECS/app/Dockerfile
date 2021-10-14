FROM node:12-alpine

# Set the working directory to /app
WORKDIR '/app'

# Copy package.json to the working directory so we can install all the dependencies
COPY package.json .

# Install any needed packages specified in package.json
RUN npm install && npm install typescript -g

# Copying the rest of the code to the working directory
COPY . .

# Make port 3001 available to the world outside this container
EXPOSE 3000

#Builds the TS code
RUN tsc

# Run index.js when the container launches
CMD [ "node", "build/server.js" ]