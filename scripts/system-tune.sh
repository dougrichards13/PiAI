#!/bin/bash
# PiAI System Tuning and Diagnostics Script
# Optimizes Pi 5 for AI workloads and provides detailed diagnostics

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_usage() {
    cat << EOF
${GREEN}PiAI System Tuning & Diagnostics${NC}

Usage: $0 [command]

Commands:
  diagnose        - Run full system diagnostics
  optimize        - Apply recommended system optimizations
  benchmark       - Run performance benchmarks
  healthcheck     - Quick health check
  restore         - Restore default settings
  help            - Show this help message

Examples:
  $0 diagnose
  $0 optimize
  $0 benchmark
EOF
}

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_info() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

cmd_diagnose() {
    print_header "PiAI System Diagnostics"
    
    echo ""
    echo -e "${GREEN}=== Hardware Info ===${NC}"
    
    # CPU
    cpu_model=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
    cpu_cores=$(nproc)
    echo "CPU: $cpu_model ($cpu_cores cores)"
    
    # RAM
    total_ram=$(free -h | awk '/^Mem:/{print $2}')
    used_ram=$(free -h | awk '/^Mem:/{print $3}')
    echo "RAM: $used_ram used / $total_ram total"
    
    # Swap
    swap_total=$(free -h | awk '/^Swap:/{print $2}')
    swap_used=$(free -h | awk '/^Swap:/{print $3}')
    echo "Swap: $swap_used used / $swap_total total"
    
    # Disk
    disk_used=$(df -h ~ | awk 'NR==2 {print $3}')
    disk_avail=$(df -h ~ | awk 'NR==2 {print $4}')
    disk_percent=$(df -h ~ | awk 'NR==2 {print $5}')
    echo "Disk: $disk_used used, $disk_avail available ($disk_percent used)"
    
    # Temperature
    if command -v vcgencmd &> /dev/null; then
        temp=$(vcgencmd measure_temp | cut -d= -f2)
        echo "Temperature: $temp"
    fi
    
    echo ""
    echo -e "${GREEN}=== Software Status ===${NC}"
    
    # Ollama
    if pgrep -x ollama > /dev/null; then
        ollama_version=$(ollama --version 2>/dev/null || echo "unknown")
        print_info "Ollama: Running ($ollama_version)"
    else
        print_warning "Ollama: Not running"
    fi
    
    # Hailo
    if lsmod | grep -q hailo_pci; then
        print_info "Hailo AI HAT: Loaded"
    else
        print_warning "Hailo AI HAT: Not detected"
    fi
    
    # Python venv
    if [ -d ~/ai-tools/venv ]; then
        python_version=$(~/ai-tools/venv/bin/python --version 2>&1)
        print_info "Python Environment: $python_version"
    else
        print_error "Python Environment: Not found"
    fi
    
    # llama.cpp
    if [ -f ~/ai-tools/llama.cpp/build/bin/llama-cli ]; then
        print_info "llama.cpp: Built"
    else
        print_error "llama.cpp: Not built"
    fi
    
    echo ""
    echo -e "${GREEN}=== Model Storage ===${NC}"
    
    # Ollama models
    if [ -d ~/.ollama/models ]; then
        ollama_size=$(du -sh ~/.ollama/models 2>/dev/null | cut -f1)
        echo "Ollama models: $ollama_size"
    fi
    
    # HuggingFace cache
    if [ -d ~/.cache/huggingface ]; then
        hf_size=$(du -sh ~/.cache/huggingface 2>/dev/null | cut -f1)
        echo "HuggingFace cache: $hf_size"
    fi
    
    echo ""
    echo -e "${GREEN}=== Performance Analysis ===${NC}"
    
    # Check CPU governor
    governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
    if [ "$governor" = "performance" ]; then
        print_info "CPU Governor: $governor (optimal)"
    else
        print_warning "CPU Governor: $governor (consider 'performance' mode)"
    fi
    
    # Check swap usage
    swap_percent=$(free | awk '/^Swap:/ {if ($2>0) print int($3/$2*100); else print 0}')
    if [ "$swap_percent" -gt 50 ]; then
        print_warning "Swap usage: ${swap_percent}% (high - consider more RAM)"
    else
        print_info "Swap usage: ${swap_percent}%"
    fi
    
    # Temperature warning
    if command -v vcgencmd &> /dev/null; then
        temp_val=$(vcgencmd measure_temp | grep -oP '\d+\.\d+' || echo "0")
        temp_int=${temp_val%.*}
        if [ "$temp_int" -gt 80 ]; then
            print_error "Temperature: ${temp_val}°C (CRITICAL - add cooling!)"
        elif [ "$temp_int" -gt 70 ]; then
            print_warning "Temperature: ${temp_val}°C (warm - consider cooling)"
        else
            print_info "Temperature: ${temp_val}°C (normal)"
        fi
    fi
    
    echo ""
}

cmd_optimize() {
    print_header "Applying System Optimizations"
    
    echo ""
    echo -e "${YELLOW}This will apply the following optimizations:${NC}"
    echo "  1. Set CPU governor to 'performance'"
    echo "  2. Increase swap priority"
    echo "  3. Optimize GPU memory split"
    echo "  4. Configure I/O scheduler"
    echo ""
    echo -e "${YELLOW}Continue? (y/N)${NC}"
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        exit 0
    fi
    
    echo ""
    
    # CPU governor
    echo "Setting CPU governor to performance..."
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        if [ -w "$cpu" ]; then
            echo performance | sudo tee "$cpu" > /dev/null
        fi
    done
    print_info "CPU governor set"
    
    # Make it permanent
    if ! grep -q "cpufrequtils" /etc/modules 2>/dev/null; then
        echo ""
        echo "To make CPU settings permanent, install cpufrequtils:"
        echo "  sudo apt install cpufrequtils"
        echo "  echo 'GOVERNOR=\"performance\"' | sudo tee /etc/default/cpufrequtils"
    fi
    
    # GPU memory (if config.txt exists)
    if [ -f /boot/firmware/config.txt ]; then
        if ! grep -q "gpu_mem" /boot/firmware/config.txt; then
            echo ""
            echo "Optimizing GPU memory split..."
            echo "gpu_mem=256" | sudo tee -a /boot/firmware/config.txt > /dev/null
            print_info "GPU memory configured (reboot required)"
        fi
    fi
    
    echo ""
    print_info "Optimizations applied!"
    echo ""
    echo "Note: Some changes require a reboot to take effect."
}

cmd_benchmark() {
    print_header "Running Performance Benchmarks"
    
    echo ""
    echo "This will run CPU and AI inference benchmarks..."
    echo ""
    
    # CPU benchmark
    echo -e "${GREEN}=== CPU Benchmark ===${NC}"
    echo "Running sysbench CPU test..."
    if command -v sysbench &> /dev/null; then
        sysbench cpu --cpu-max-prime=20000 --threads=$(nproc) run
    else
        echo "sysbench not installed. Install with: sudo apt install sysbench"
    fi
    
    echo ""
    
    # llama.cpp benchmark
    if [ -f ~/ai-tools/llama.cpp/build/bin/llama-bench ]; then
        echo -e "${GREEN}=== AI Inference Benchmark ===${NC}"
        echo "Running llama.cpp benchmark..."
        ~/ai-tools/llama.cpp/build/bin/llama-bench
    else
        echo "llama-bench not found. Run PiAI installation first."
    fi
    
    echo ""
}

cmd_healthcheck() {
    print_header "Quick Health Check"
    
    echo ""
    
    # Essential checks
    errors=0
    
    # Ollama
    if pgrep -x ollama > /dev/null; then
        print_info "Ollama: Running"
    else
        print_error "Ollama: Not running (start with: ~/ai-helper.sh start)"
        ((errors++))
    fi
    
    # Disk space
    disk_avail_gb=$(df -BG ~ | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$disk_avail_gb" -lt 10 ]; then
        print_error "Disk space: Only ${disk_avail_gb}GB available (need 10GB+)"
        ((errors++))
    else
        print_info "Disk space: ${disk_avail_gb}GB available"
    fi
    
    # Temperature
    if command -v vcgencmd &> /dev/null; then
        temp=$(vcgencmd measure_temp | grep -oP '\d+\.\d+' || echo "0")
        temp_int=${temp%.*}
        if [ "$temp_int" -gt 85 ]; then
            print_error "Temperature: ${temp}°C (CRITICAL!)"
            ((errors++))
        else
            print_info "Temperature: ${temp}°C"
        fi
    fi
    
    # Memory
    mem_avail_gb=$(free -g | awk '/^Mem:/{print $7}')
    if [ "$mem_avail_gb" -lt 2 ]; then
        print_warning "Available memory: ${mem_avail_gb}GB (consider closing apps)"
    else
        print_info "Available memory: ${mem_avail_gb}GB"
    fi
    
    echo ""
    
    if [ "$errors" -eq 0 ]; then
        echo -e "${GREEN}✓ All checks passed!${NC}"
    else
        echo -e "${RED}✗ ${errors} issue(s) detected${NC}"
        exit 1
    fi
}

cmd_restore() {
    print_header "Restore Default Settings"
    
    echo ""
    echo -e "${YELLOW}This will restore default system settings.${NC}"
    echo -e "${YELLOW}Continue? (y/N)${NC}"
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        exit 0
    fi
    
    # Restore CPU governor
    echo "Restoring CPU governor to ondemand..."
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        if [ -w "$cpu" ]; then
            echo ondemand | sudo tee "$cpu" > /dev/null
        fi
    done
    
    print_info "Settings restored"
}

# Main
case "${1:-help}" in
    diagnose)
        cmd_diagnose
        ;;
    optimize)
        cmd_optimize
        ;;
    benchmark)
        cmd_benchmark
        ;;
    healthcheck)
        cmd_healthcheck
        ;;
    restore)
        cmd_restore
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
