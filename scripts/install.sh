#!/bin/bash
# Smart Factory PiAI Installation Script
# Automated setup for Raspberry Pi 5 AI environment

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Installation directory
AI_TOOLS_DIR="$HOME/ai-tools"

print_header() {
    echo -e "${BLUE}"
    echo "============================================================"
    echo "         Smart Factory PiAI Installation"
    echo "         Raspberry Pi 5 AI Environment Setup"
    echo "============================================================"
    echo -e "${NC}"
}

print_step() {
    echo -e "${GREEN}==>${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

check_system() {
    print_step "Checking system requirements..."
    
    # Check if running on ARM64
    if [ "$(uname -m)" != "aarch64" ]; then
        print_error "This script is designed for ARM64 (aarch64) architecture"
        exit 1
    fi
    
    # Check for Raspberry Pi 5
    if ! grep -q "Raspberry Pi 5" /proc/cpuinfo 2>/dev/null; then
        print_warning "Not running on Raspberry Pi 5. Continuing anyway..."
    fi
    
    # Check RAM
    total_ram=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$total_ram" -lt 7 ]; then
        print_warning "Less than 8GB RAM detected. Some models may not work well."
    fi
    
    # Check disk space (need at least 20GB free)
    available_space=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$available_space" -lt 20 ]; then
        print_error "Insufficient disk space. Need 20GB free, found ${available_space}GB"
        exit 1
    fi
    
    # Check temperature if vcgencmd available
    if command -v vcgencmd &> /dev/null; then
        temp=$(vcgencmd measure_temp | grep -oP '\d+\.\d+' || echo "0")
        temp_int=${temp%.*}
        if [ "$temp_int" -gt 75 ]; then
            print_warning "System temperature is high (${temp}°C). Consider cooling before install."
            echo -e "${YELLOW}Continue anyway? (y/N)${NC}"
            read -r response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                exit 0
            fi
        fi
    fi
    
    print_success "System check completed"
}

install_dependencies() {
    print_step "Installing system dependencies..."
    
    sudo apt update
    sudo apt install -y \
        python3-pip \
        python3-venv \
        git \
        build-essential \
        cmake \
        curl \
        || { print_error "Failed to install dependencies"; exit 1; }
    
    print_success "Dependencies installed"
}

install_ollama() {
    print_step "Installing Ollama..."
    
    if command -v ollama &> /dev/null; then
        print_success "Ollama already installed"
        return
    fi
    
    curl -fsSL https://ollama.com/install.sh | sh || {
        print_error "Failed to install Ollama"
        exit 1
    }
    
    print_success "Ollama installed"
}

setup_ollama_privacy() {
    print_step "Configuring Ollama for privacy..."
    
    cat > "$HOME/.ollama_env" << 'EOF'
# Ollama Privacy Configuration
export OLLAMA_TELEMETRY=false
export OLLAMA_ANALYTICS=false
export OLLAMA_MODELS=$HOME/.ollama/models
export OLLAMA_HOST=127.0.0.1:11434
export OLLAMA_AUTO_UPDATE=false
EOF
    
    print_success "Ollama privacy configured"
}

setup_huggingface_privacy() {
    print_step "Configuring Hugging Face for offline operation..."
    
    cat > "$HOME/.huggingface_env" << 'EOF'
# Hugging Face Privacy Configuration
export HF_HUB_DISABLE_TELEMETRY=1
export HF_HOME=$HOME/.cache/huggingface
export HF_DATASETS_CACHE=$HOME/.cache/huggingface/datasets
export TRANSFORMERS_CACHE=$HOME/.cache/huggingface/transformers
# Note: Offline mode disabled by default to allow initial model downloads
# Uncomment these lines after downloading models if you want full offline operation:
# export HF_HUB_OFFLINE=1
# export TRANSFORMERS_OFFLINE=1
EOF
    
    print_success "Hugging Face privacy configured (offline mode: disabled for initial setup)"
}

setup_environment() {
    print_step "Setting up environment..."
    
    # Add to bashrc if not already there
    if ! grep -q "Smart Factory PiAI" "$HOME/.bashrc"; then
        cat >> "$HOME/.bashrc" << 'EOF'

# Smart Factory PiAI Environment
source ~/.ollama_env 2>/dev/null || true
source ~/.huggingface_env 2>/dev/null || true
alias ai-env='source ~/ai-tools/venv/bin/activate'
EOF
    fi
    
    # Source for current session
    source "$HOME/.ollama_env"
    source "$HOME/.huggingface_env"
    
    print_success "Environment configured"
}

build_llama_cpp() {
    print_step "Building llama.cpp (this may take 10-15 minutes)..."
    
    mkdir -p "$AI_TOOLS_DIR"
    cd "$AI_TOOLS_DIR"
    
    if [ ! -d "llama.cpp" ]; then
        git clone https://github.com/ggerganov/llama.cpp.git || {
            print_error "Failed to clone llama.cpp"
            exit 1
        }
    fi
    
    cd llama.cpp
    
    # Clean any partial builds
    if [ -d "build" ]; then
        print_step "Cleaning previous build..."
        rm -rf build
    fi
    
    cmake -B build -DLLAMA_CURL=OFF
    cmake --build build --config Release -j$(nproc) || {
        print_error "Failed to build llama.cpp"
        print_error "Cleaning build directory for next attempt..."
        rm -rf build
        exit 1
    }
    
    print_success "llama.cpp built successfully"
}

setup_python_env() {
    print_step "Setting up Python environment (this may take 15-20 minutes)..."
    
    cd "$AI_TOOLS_DIR"
    
    if [ ! -d "venv" ]; then
        python3 -m venv venv || {
            print_error "Failed to create Python virtual environment"
            exit 1
        }
    fi
    
    source venv/bin/activate
    
    # Upgrade pip
    pip install --upgrade pip
    
    # Install AI packages
    pip install --no-cache-dir \
        transformers \
        datasets \
        torch \
        torchvision \
        torchaudio \
        accelerate \
        peft \
        bitsandbytes \
        sentencepiece \
        protobuf \
        requests \
        || {
        print_error "Failed to install Python packages"
        exit 1
    }
    
    deactivate
    
    print_success "Python environment set up"
}

start_ollama() {
    print_step "Starting Ollama server..."
    
    if pgrep -x ollama > /dev/null; then
        print_success "Ollama already running"
        return
    fi
    
    nohup ollama serve > "$HOME/ollama.log" 2>&1 &
    sleep 3
    
    if pgrep -x ollama > /dev/null; then
        print_success "Ollama server started"
    else
        print_warning "Ollama may not have started properly. Check ~/ollama.log"
    fi
}

monitor_temperature() {
    if command -v vcgencmd &> /dev/null; then
        temp=$(vcgencmd measure_temp | grep -oP '\d+\.\d+' || echo "0")
        temp_int=${temp%.*}
        if [ "$temp_int" -gt 80 ]; then
            print_warning "Temperature: ${temp}°C - Consider adding cooling"
        fi
    fi
}

setup_helper_script() {
    print_step "Setting up helper scripts..."
    
    # Make scripts executable
    chmod +x "$HOME/PiAI/scripts/ai-helper.sh"
    chmod +x "$HOME/PiAI/scripts/system-tune.sh"
    
    # Create symlinks in home directory for easy access
    ln -sf "$HOME/PiAI/scripts/ai-helper.sh" "$HOME/ai-helper.sh"
    ln -sf "$HOME/PiAI/scripts/system-tune.sh" "$HOME/system-tune.sh"
    
    print_success "Helper scripts ready"
}

print_completion() {
    echo ""
    echo -e "${GREEN}"
    echo "============================================================"
    echo "         🎉 Installation Complete! 🎉"
    echo "============================================================"
    echo -e "${NC}"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Restart your terminal or run:"
    echo -e "   ${BLUE}source ~/.bashrc${NC}"
    echo ""
    echo "2. Check system status:"
    echo -e "   ${BLUE}~/ai-helper.sh status${NC}"
    echo ""
    echo "3. Run system diagnostics (optional):"
    echo -e "   ${BLUE}~/system-tune.sh diagnose${NC}"
    echo ""
    echo "4. Download your first AI model:"
    echo -e "   ${BLUE}~/ai-helper.sh pull phi3:mini${NC}"
    echo ""
    echo "5. Start chatting:"
    echo -e "   ${BLUE}~/ai-helper.sh run phi3:mini${NC}"
    echo ""
    echo "📚 Documentation:"
    echo "   - JumpStart Guide: ~/PiAI/docs/JumpStart.md"
    echo "   - Full Reference: ~/PiAI/docs/Smart_Factory_PiAI.md"
    echo ""
    echo "💡 Example Projects:"
    echo "   - Simple Chatbot: ~/PiAI/examples/simple-chatbot/"
    echo "   - Fine-tuning: ~/PiAI/examples/finetune-example.py"
    echo ""
    echo "🔒 Privacy: All AI processing is local. No data leaves your device."
    echo ""
    echo -e "${GREEN}Welcome to Smart Factory PiAI!${NC}"
    echo ""
}

# Main installation flow
main() {
    print_header
    
    check_system
    install_dependencies
    install_ollama
    setup_ollama_privacy
    setup_huggingface_privacy
    setup_environment
    build_llama_cpp
    monitor_temperature
    setup_python_env
    monitor_temperature
    start_ollama
    setup_helper_script
    
    print_completion
}

# Run installation
main
