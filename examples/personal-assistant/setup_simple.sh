#!/bin/bash
# Simple Assistant Setup - Using Vosk (proven to work on Pi)

set -e

echo "================================"
echo "  PiAI Simple Assistant Setup"
echo "================================"
echo

cd ~/PiAI/examples/personal-assistant

# Install Vosk
echo "[1/3] Installing Vosk..."
source ~/ai-tools/venv/bin/activate
pip install vosk pyaudio

# Download Vosk model (small, fast for Pi)
echo "[2/3] Downloading speech model (40MB)..."
if [ ! -d "vosk-model-small-en-us-0.15" ]; then
    wget -q --show-progress https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip
    unzip -q vosk-model-small-en-us-0.15.zip
    rm vosk-model-small-en-us-0.15.zip
    echo "Model downloaded!"
else
    echo "Model already exists"
fi

# Make executable
chmod +x simple_assistant.py

# Check Ollama
echo "[3/3] Checking Ollama..."
if pgrep -x ollama > /dev/null; then
    echo "Ollama running"
else
    echo "Starting Ollama..."
    ~/ai-helper.sh start
fi

# Check for model
if ~/ai-helper.sh models | grep -q phi3; then
    echo "phi3:mini found"
else
    echo "WARNING: phi3:mini not found"
    echo "Download with: ~/ai-helper.sh pull phi3:mini"
fi

echo
echo "================================"
echo "  Setup Complete!"
echo "================================"
echo
echo "To run:"
echo "  cd ~/PiAI/examples/personal-assistant"
echo "  source ~/ai-tools/venv/bin/activate"
echo "  ./simple_assistant.py"
echo
echo "Then press Enter and speak!"
echo
