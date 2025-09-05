#!/bin/bash

set -e

# Log functions with colors
log_info() {
  echo -e "\033[34m[INFO]\033[0m [$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log_success() {
  echo -e "\033[32m[SUCCESS]\033[0m [$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log_warn() {
  echo -e "\033[33m[WARN]\033[0m [$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log_error() {
  echo -e "\033[31m[ERROR]\033[0m [$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log_info "=== Starting Elasticsearch Configuration Copy & Initialization ==="

# Define paths
BELLA_WORKFLOW_ES_DIR="/host-bella-workflow/scripts"
LOCAL_SCRIPTS_DIR="/scripts"

# Check if bella-workflow elasticsearch directory exists
if [ -d "$BELLA_WORKFLOW_ES_DIR" ]; then
    log_success "Found bella-workflow elasticsearch directory at $BELLA_WORKFLOW_ES_DIR"
    
    # Copy all files from bella-workflow to local scripts directory
    log_info "Copying configuration files from bella-workflow..."
    
    # Copy the entire scripts directory structure
    if [ -d "$BELLA_WORKFLOW_ES_DIR/config" ]; then
        mkdir -p "$LOCAL_SCRIPTS_DIR/config"
        cp -r "$BELLA_WORKFLOW_ES_DIR/config"/* "$LOCAL_SCRIPTS_DIR/config/"
        log_success "✓ Copied config directory"
    fi
    
    # Copy individual script files
    for script_file in init-elasticsearch.sh monitor-indices.sh; do
        if [ -f "$BELLA_WORKFLOW_ES_DIR/$script_file" ]; then
            cp "$BELLA_WORKFLOW_ES_DIR/$script_file" "$LOCAL_SCRIPTS_DIR/"
            chmod +x "$LOCAL_SCRIPTS_DIR/$script_file"
            log_success "✓ Copied and made executable: $script_file"
        else
            log_warn "✗ Script not found: $script_file"
        fi
    done
    
    log_success "Configuration files copied successfully from bella-workflow"
    
    # Now execute the bella-workflow initialization script
    if [ -f "$LOCAL_SCRIPTS_DIR/init-elasticsearch.sh" ]; then
        log_info "Executing bella-workflow initialization script..."
        exec "$LOCAL_SCRIPTS_DIR/init-elasticsearch.sh"
    else
        log_error "init-elasticsearch.sh not found after copy!"
        exit 1
    fi
else
    log_warn "Bella-workflow elasticsearch directory not found at $BELLA_WORKFLOW_ES_DIR"
    log_info "Creating basic standalone configuration..."
    
    # Create config directory
    mkdir -p "$LOCAL_SCRIPTS_DIR/config"
    
    # Create basic mappings
    cat > "$LOCAL_SCRIPTS_DIR/config/workflow_run_log_mappings.json" << 'EOF'
{
  "properties": {
    "ctime": {"type": "date"},
    "timestamp": {"type": "date"},
    "level": {"type": "keyword"},
    "message": {"type": "text", "analyzer": "standard"},
    "workflowId": {"type": "keyword"},
    "nodeId": {"type": "keyword"},
    "status": {"type": "keyword"},
    "error": {"type": "text"},
    "userId": {"type": "long"},
    "tenantId": {"type": "keyword"},
    "bellaTraceId": {"type": "keyword"},
    "elapsedTime": {"type": "long"},
    "event": {"type": "keyword"},
    "workflowRunId": {"type": "keyword"},
    "nodeType": {"type": "keyword"},
    "nodeTitle": {"type": "text"},
    "userName": {"type": "keyword"},
    "triggerFrom": {"type": "keyword"}
  }
}
EOF
    
    # Create basic policy
    cat > "$LOCAL_SCRIPTS_DIR/config/workflow_run_log_policy.json" << 'EOF'
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": {
            "max_age": "1d"
          }
        }
      },
      "delete": {
        "min_age": "7d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
EOF
    
    # Create basic initialization script
    cat > "$LOCAL_SCRIPTS_DIR/init-elasticsearch.sh" << 'EOF'
#!/bin/bash

# Log functions with colors
log_info() {
  echo -e "\033[34m[INFO]\033[0m [$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log_success() {
  echo -e "\033[32m[SUCCESS]\033[0m [$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log_warn() {
  echo -e "\033[33m[WARN]\033[0m [$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Configure Elasticsearch
log_info "Configuring Elasticsearch..."
cat > /usr/share/elasticsearch/config/elasticsearch.yml << ESEOF
ingest.geoip.downloader.enabled: false
network.host: 0.0.0.0
http.cors.enabled: true
http.cors.allow-origin: "*"
ESEOF

# Wait for Elasticsearch to be available
log_info "Waiting for Elasticsearch service..."
MAX_RETRIES=30
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  log_info "Attempting to connect to Elasticsearch ($((RETRY_COUNT+1))/$MAX_RETRIES)"
  if curl -s "http://localhost:9200" > /dev/null; then
    log_success "Elasticsearch service is now available!"
    break
  else
    log_info "Waiting for Elasticsearch service to become available..."
    RETRY_COUNT=$((RETRY_COUNT+1))
    sleep 5
  fi
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
  log_warn "Warning: Elasticsearch service startup timed out"
fi

# Define index prefix
INDEX_PREFIX="${ELASTICSEARCH_RUN_LOG_INDEX:-workflow_run_log_test}"
log_info "Using index prefix: ${INDEX_PREFIX}"

# Create lifecycle policy
log_info "Creating lifecycle policy..."
curl -s -X PUT "http://localhost:9200/_ilm/policy/${INDEX_PREFIX}_policy" -H 'Content-Type: application/json' -d @/scripts/config/workflow_run_log_policy.json

# Create index template
log_info "Creating index template..."
cat > /tmp/template.json << TEMPLATEEOF
{
  "index_patterns": ["${INDEX_PREFIX}_*"],
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0,
    "index.lifecycle.name": "${INDEX_PREFIX}_policy",
    "index.lifecycle.rollover_alias": "${INDEX_PREFIX}"
  },
  "mappings": $(cat /scripts/config/workflow_run_log_mappings.json)
}
TEMPLATEEOF

curl -s -X PUT "http://localhost:9200/_template/${INDEX_PREFIX}_template" -H 'Content-Type: application/json' -d @/tmp/template.json

# Create today's index
CURRENT_DATE=$(date +"%Y-%m-%d")
log_info "Creating today's index: ${INDEX_PREFIX}_${CURRENT_DATE}"

curl -s -X PUT "http://localhost:9200/${INDEX_PREFIX}_${CURRENT_DATE}" -H 'Content-Type: application/json' -d '{"aliases":{"'${INDEX_PREFIX}'":{"is_write_index":true}}}'

log_success "Elasticsearch initialization complete!"

# Simple monitoring loop
while true; do
  sleep 3600
done
EOF
    
    chmod +x "$LOCAL_SCRIPTS_DIR/init-elasticsearch.sh"
    
    log_success "Basic configuration created"
    
    # Execute the basic initialization script
    exec "$LOCAL_SCRIPTS_DIR/init-elasticsearch.sh"
fi