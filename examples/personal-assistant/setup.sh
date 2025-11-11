#!/bin/bash
# PiAI Personal Assistant Setup Script
# Installs all dependencies for the voice assistant

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}"
echo "============================================"
echo "  PiAI Personal Assistant Setup"
echo "============================================"
echo -e "${NC}"

# Check if we're in the right directory
if [ ! -f "assistant.py" ]; then
    echo -e "${RED}Error: Please run this from the personal-assistant directory${NC}"
    echo "  cd ~/PiAI/examples/personal-assistant"
    exit 1
fi

# Check if PiAI is installed
if [ ! -d ~/ai-tools/venv ]; then
    echo -e "${RED}Error: PiAI not installed${NC}"
    echo "Please install PiAI first: ~/PiAI/scripts/install.sh"
    exit 1
fi

# Check Ollama
if ! pgrep -x ollama > /dev/null; then
    echo -e "${YELLOW}⚠️  Ollama is not running${NC}"
    echo "Starting Ollama..."
    ~/ai-helper.sh start
fi

# Install system dependencies
echo -e "${GREEN}📦 Installing system dependencies...${NC}"
sudo apt update
sudo apt install -y portaudio19-dev espeak ffmpeg

# Activate venv and install Python packages
echo -e "${GREEN}🐍 Installing Python packages...${NC}"
source ~/ai-tools/venv/bin/activate
pip install -r requirements.txt

# Make assistant executable
chmod +x assistant.py

# Check for phi3:mini
echo -e "${GREEN}🧠 Checking for AI model...${NC}"
if ! ~/ai-helper.sh models | grep -q phi3; then
    echo -e "${YELLOW}⚠️  phi3:mini not found${NC}"
    echo "Download with: ~/ai-helper.sh pull phi3:mini"
    echo "(This will take a few minutes)"
fi

# Test microphone
echo -e "${GREEN}🎤 Testing microphone...${NC}"
if arecord -l | grep -q "USB"; then
    echo -e "${GREEN}✅ USB microphone detected!${NC}"
else
    echo -e "${YELLOW}⚠️  No USB microphone found${NC}"
    echo "Make sure your microphone is connected"
fi

# Test speakers
echo -e "${GREEN}🔊 Testing audio output...${NC}"
if command -v espeak &> /dev/null; then
    espeak -v en "Audio test successful" 2>/dev/null || true
    echo -e "${GREEN}✅ Audio working!${NC}"
else
    echo -e "${RED}❌ eSpeak not installed correctly${NC}"
fi

echo ""
echo -e "${GREEN}============================================"
echo "  ✅ Setup Complete!"
echo "============================================${NC}"
echo ""
echo "To run the assistant:"
echo "  source ~/ai-tools/venv/bin/activate"
echo "  ./assistant.py"
echo ""
echo "Configuration file: ~/.piai_assistant_config.json"
echo ""
