#!/bin/bash

# Bella Services Nginx Startup Script
# This script starts an nginx container to proxy workflow.bella.top and knowledge.bella.top

set -e

# Configuration variables
CONTAINER_NAME="bella-nginx-proxy"
NGINX_IMAGE="nginx:alpine"
HTTP_PORT="80"
HTTPS_PORT="443"
NGINX_CONF_PATH="$(pwd)/nginx-sites.conf"
SSL_CERT_PATH="$(pwd)/shared-nginx/ssl"

# Color output functions
print_info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

print_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

print_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

# Check if required files exist
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    if [ ! -f "$NGINX_CONF_PATH" ]; then
        print_error "Nginx configuration file not found: $NGINX_CONF_PATH"
        exit 1
    fi
    
    if [ ! -d "$SSL_CERT_PATH" ]; then
        print_error "SSL certificates directory not found: $SSL_CERT_PATH"
        exit 1
    fi
    
    # Check for required SSL certificates
    local required_certs=(
        "workflow-fullchain.pem"
        "workflow-privkey.pem"
        "knowledge-fullchain.pem"
        "knowledge-privkey.pem"
    )
    
    for cert in "${required_certs[@]}"; do
        if [ ! -f "$SSL_CERT_PATH/$cert" ]; then
            print_error "SSL certificate not found: $SSL_CERT_PATH/$cert"
            exit 1
        fi
    done
    
    print_success "All prerequisites check passed"
}

# Stop existing container if running
stop_existing_container() {
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        print_info "Stopping existing container: $CONTAINER_NAME"
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
    fi
    
    if docker ps -aq -f name="$CONTAINER_NAME" | grep -q .; then
        print_info "Removing existing container: $CONTAINER_NAME"
        docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
    fi
}

# Create nginx container
start_nginx_container() {
    print_info "Starting nginx container: $CONTAINER_NAME"
    
    docker run -d \
        --name "$CONTAINER_NAME" \
        --restart unless-stopped \
        -p "$HTTP_PORT:80" \
        -p "$HTTPS_PORT:443" \
        -v "$NGINX_CONF_PATH:/etc/nginx/conf.d/default.conf:ro" \
        -v "$SSL_CERT_PATH:/etc/nginx/ssl:ro" \
        --network host \
        "$NGINX_IMAGE"
    
    print_success "Nginx container started successfully"
}

# Test nginx configuration
test_nginx_config() {
    print_info "Testing nginx configuration..."
    
    if docker exec "$CONTAINER_NAME" nginx -t >/dev/null 2>&1; then
        print_success "Nginx configuration is valid"
    else
        print_error "Nginx configuration test failed"
        print_info "Showing nginx configuration test output:"
        docker exec "$CONTAINER_NAME" nginx -t
        return 1
    fi
}

# Check container health
check_container_health() {
    print_info "Checking container health..."
    
    # Wait a moment for the container to start
    sleep 3
    
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        print_success "Container is running"
        
        # Check if nginx is responding
        local container_ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_NAME" 2>/dev/null || echo "localhost")
        if curl -s -o /dev/null -w "%{http_code}" "http://$container_ip" | grep -q "200\|301\|302"; then
            print_success "Nginx is responding to HTTP requests"
        else
            print_warning "Nginx may not be responding correctly"
        fi
    else
        print_error "Container failed to start"
        return 1
    fi
}

# Show container logs
show_container_logs() {
    print_info "Recent container logs:"
    docker logs --tail 20 "$CONTAINER_NAME" 2>&1 | sed 's/^/  /'
}

# Show status information
show_status() {
    print_success "Bella Services Nginx Proxy is running!"
    echo ""
    echo "Container Details:"
    echo "  Name: $CONTAINER_NAME"
    echo "  Image: $NGINX_IMAGE"
    echo "  HTTP Port: $HTTP_PORT"
    echo "  HTTPS Port: $HTTPS_PORT"
    echo ""
    echo "Configured Services:"
    echo "  workflow.bella.top -> bella-workflow containers"
    echo "  knowledge.bella.top -> bella-file-api containers"
    echo ""
    echo "Management Commands:"
    echo "  View logs: docker logs -f $CONTAINER_NAME"
    echo "  Stop: docker stop $CONTAINER_NAME"
    echo "  Restart: docker restart $CONTAINER_NAME"
    echo "  Remove: docker rm -f $CONTAINER_NAME"
}

# Main execution
main() {
    print_info "Starting Bella Services Nginx Proxy..."
    
    check_prerequisites
    stop_existing_container
    start_nginx_container
    
    if test_nginx_config && check_container_health; then
        show_status
    else
        print_error "Failed to start nginx proxy properly"
        show_container_logs
        exit 1
    fi
}

# Handle script arguments
case "${1:-}" in
    stop)
        print_info "Stopping Bella Services Nginx Proxy..."
        stop_existing_container
        print_success "Container stopped and removed"
        ;;
    logs)
        docker logs -f "$CONTAINER_NAME"
        ;;
    status)
        if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
            print_success "Container $CONTAINER_NAME is running"
            docker ps -f name="$CONTAINER_NAME"
        else
            print_warning "Container $CONTAINER_NAME is not running"
        fi
        ;;
    restart)
        print_info "Restarting Bella Services Nginx Proxy..."
        stop_existing_container
        main
        ;;
    *)
        main
        ;;
esac