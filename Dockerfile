# Use the official NGINX image
FROM nginx:latest

# Copy custom configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80
