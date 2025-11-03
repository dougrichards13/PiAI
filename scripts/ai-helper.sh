#!/bin/bash
# AI Helper Script for Raspberry Pi 5
# Quick commands for common AI tasks

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Source privacy settings
source ~/.ollama_env 2>/dev/null || true
source ~/.huggingface_env 2>/dev/null || true

show_usage() {
    cat << EOF
${GREEN}AI Helper Script for Raspberry Pi 5${NC}

Usage: $0 [command]

Commands:
  status          - Show AI system status
  start           - Start Ollama server
  stop            - Stop Ollama server
  models          - List installed Ollama models
  pull <model>    - Download a model from Ollama
  run <model>     - Run a model interactively
  benchmark       - Run llama.cpp benchmark
  cleanup         - Clean up old models and cache
  env             - Show environment variables
  temp            - Show Pi temperature
  memory          - Show memory usage
  help            - Show this help message

Examples:
  $0 status
  $0 pull phi3:mini
  $0 run phi3:mini
  $0 benchmark

${YELLOW}Privacy Status: All operations are local-only${NC}
EOF
}

check_ollama_running() {
    pgrep -x ollama > /dev/null
}

cmd_status() {
    echo -e "${GREEN}=== AI System Status ===${NC}"
    
    # Ollama
    if check_ollama_running; then
        echo -e "Ollama Server: ${GREEN}Running${NC}"
    else
        echo -e "Ollama Server: ${RED}Stopped${NC}"
    fi
    
    # Hailo
    if lsmod | grep -q hailo_pci; then
        echo -e "Hailo AI Hat: ${GREEN}Loaded${NC}"
    else
        echo -e "Hailo AI Hat: ${RED}Not loaded${NC}"
    fi
    
    # Python env
    if [ -d ~/ai-tools/venv ]; then
        echo -e "Python Environment: ${GREEN}Installed${NC}"
    else
        echo -e "Python Environment: ${RED}Not found${NC}"
    fi
    
    # llama.cpp
    if [ -f ~/ai-tools/llama.cpp/build/bin/llama-cli ]; then
        echo -e "llama.cpp: ${GREEN}Built${NC}"
    else
        echo -e "llama.cpp: ${RED}Not built${NC}"
    fi
    
    echo ""
    cmd_memory
    cmd_temp
}

cmd_start() {
    if check_ollama_running; then
        echo -e "${YELLOW}Ollama is already running${NC}"
        return
    fi
    
    echo -e "${GREEN}Starting Ollama server...${NC}"
    nohup ollama serve > ~/ollama.log 2>&1 &
    sleep 2
    
    if check_ollama_running; then
        echo -e "${GREEN}Ollama started successfully${NC}"
    else
        echo -e "${RED}Failed to start Ollama${NC}"
        exit 1
    fi
}

cmd_stop() {
    if ! check_ollama_running; then
        echo -e "${YELLOW}Ollama is not running${NC}"
        return
    fi
    
    echo -e "${GREEN}Stopping Ollama server...${NC}"
    pkill ollama
    sleep 1
    echo -e "${GREEN}Ollama stopped${NC}"
}

cmd_models() {
    if ! check_ollama_running; then
        echo -e "${RED}Ollama is not running. Start it with: $0 start${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}=== Installed Models ===${NC}"
    ollama list
}

cmd_pull() {
    if [ -z "$1" ]; then
        echo -e "${RED}Error: Please specify a model name${NC}"
        echo "Example: $0 pull phi3:mini"
        exit 1
    fi
    
    if ! check_ollama_running; then
        echo -e "${YELLOW}Starting Ollama server...${NC}"
        cmd_start
    fi
    
    echo -e "${GREEN}Pulling model: $1${NC}"
    ollama pull "$1"
}

cmd_run() {
    if [ -z "$1" ]; then
        echo -e "${RED}Error: Please specify a model name${NC}"
        echo "Example: $0 run phi3:mini"
        exit 1
    fi
    
    if ! check_ollama_running; then
        echo -e "${YELLOW}Starting Ollama server...${NC}"
        cmd_start
    fi
    
    echo -e "${GREEN}Running model: $1${NC}"
    echo -e "${YELLOW}(Type /bye to exit)${NC}"
    ollama run "$1"
}

cmd_benchmark() {
    if [ ! -f ~/ai-tools/llama.cpp/build/bin/llama-bench ]; then
        echo -e "${RED}llama-bench not found${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Running llama.cpp benchmark...${NC}"
    ~/ai-tools/llama.cpp/build/bin/llama-bench
}

cmd_cleanup() {
    echo -e "${YELLOW}This will remove unused models and cache. Continue? (y/N)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        exit 0
    fi
    
    echo -e "${GREEN}Cleaning up...${NC}"
    
    # Clean pip cache
    if [ -d ~/ai-tools/venv ]; then
        source ~/ai-tools/venv/bin/activate
        pip cache purge 2>/dev/null || true
        deactivate
    fi
    
    # Clean HuggingFace cache (be careful!)
    # Uncomment if you want to remove cached models
    # rm -rf ~/.cache/huggingface/hub
    
    echo -e "${GREEN}Cleanup complete${NC}"
}

cmd_env() {
    echo -e "${GREEN}=== Environment Variables ===${NC}"
    echo "OLLAMA_TELEMETRY=$OLLAMA_TELEMETRY"
    echo "OLLAMA_ANALYTICS=$OLLAMA_ANALYTICS"
    echo "OLLAMA_HOST=$OLLAMA_HOST"
    echo "OLLAMA_MODELS=$OLLAMA_MODELS"
    echo "HF_HUB_OFFLINE=$HF_HUB_OFFLINE"
    echo "HF_HUB_DISABLE_TELEMETRY=$HF_HUB_DISABLE_TELEMETRY"
}

cmd_temp() {
    if command -v vcgencmd &> /dev/null; then
        temp=$(vcgencmd measure_temp | cut -d= -f2)
        echo -e "Temperature: ${YELLOW}${temp}${NC}"
    else
        echo -e "${RED}vcgencmd not available${NC}"
    fi
}

cmd_memory() {
    echo -e "${GREEN}=== Memory Usage ===${NC}"
    free -h | grep -E "^Mem|^Swap"
}

# Main
case "${1:-help}" in
    status)
        cmd_status
        ;;
    start)
        cmd_start
        ;;
    stop)
        cmd_stop
        ;;
    models)
        cmd_models
        ;;
    pull)
        cmd_pull "$2"
        ;;
    run)
        cmd_run "$2"
        ;;
    benchmark)
        cmd_benchmark
        ;;
    cleanup)
        cmd_cleanup
        ;;
    env)
        cmd_env
        ;;
    temp)
        cmd_temp
        ;;
    memory)
        cmd_memory
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo ""
        show_usage
        exit 1
        ;;
esac
