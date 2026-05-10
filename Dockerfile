# Use the official Flutter image as the base image
FROM cirrusci/flutter:stable AS build

# Set the working directory
WORKDIR /app

# Copy the pubspec files
COPY pubspec.* ./

# Get dependencies
RUN flutter pub get

# Copy the rest of the code
COPY . .

# Build the web app
RUN flutter build web --release

# Use Nginx to serve the built app
FROM nginx:alpine

# Copy the built web app to Nginx's html directory
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom Nginx configuration if needed (optional)
# COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]