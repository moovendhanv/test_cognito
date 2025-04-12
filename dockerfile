# Use official Node.js image
FROM node:18

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of your application
COPY . .

# Default command (you can update this if needed)
CMD ["node", "index.js"]
