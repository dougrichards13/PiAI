# Smart Factory PiAI - Complete Reference Guide

**Resurfacing the Raspberry Pi 5 for AI Excellence**

*By Doug Richards, Executive Chairman, [Smart Factory](https://smartfactory.io)*

---

## Project Overview

The **Smart Factory PiAI** project transforms your Raspberry Pi 5 into a powerful, privacy-focused AI workstation. This guide helps you "resurface" your Pi—optimizing it specifically for running, experimenting with, and fine-tuning AI models entirely on-device.

### Our Hardware Configuration

This project was developed and tested with:
- **Raspberry Pi 5** - 16GB RAM (8GB minimum supported)
- **Raspberry Pi AI HAT+** with Hailo-8L NPU (26 TOPS)
- **64GB microSD Card** (Class 10, A2 rated)
- **Official 27W USB-C Power Supply**
- **Active cooling solution** (recommended for sustained AI workloads)
- **Raspberry Pi OS (64-bit)** - Debian Bookworm

### What This Project Provides

✅ **100% Local AI Processing** - Your data never leaves your device  
✅ **Privacy-First Configuration** - All telemetry and external reporting disabled  
✅ **Production-Ready Tools** - Ollama, llama.cpp, PyTorch, Transformers  
✅ **Easy-to-Use Scripts** - Automated installation and management  
✅ **Fine-Tuning Capabilities** - LoRA/PEFT for custom model training  
✅ **Beginner-Friendly** - Clear documentation for all skill levels  

---

## Realistic Expectations: What Your Pi 5 Can (and Can't) Do

### ✅ What Works Well

**Text Generation & Chat**
- Small to medium language models (1B-7B parameters)
- Response times: 2-10 tokens/second (depending on model)
- Perfect for: chatbots, creative writing, code assistance

**Image Classification**
- Real-time object detection with Hailo acceleration
- Sub-second inference for common vision tasks
- Great for: security cameras, robotics, smart home

**Fine-Tuning**
- LoRA/PEFT training on small models
- Training time: hours to days (depending on dataset)
- Excellent for: domain adaptation, custom assistants

**Model Experimentation**
- Try dozens of models without cloud costs
- Compare performance across architectures
- Learn AI/ML concepts hands-on

### ⚠️ Realistic Limitations

**Speed**
- Not as fast as cloud GPUs or desktop workstations
- Large models (13B+) may be too slow for interactive use
- Fine-tuning large models can take days

**Model Size**
- 16GB RAM limits model size to ~7B parameters (quantized)
- Very large models (70B+) won't fit in memory
- Recommend staying under 5B parameters for best experience

**Power & Heat**
- Sustained AI workloads generate significant heat
- Active cooling is **essential** for longer sessions
- Power consumption ~10-15W under heavy load

### 🎯 Sweet Spot Use Cases

This setup excels at:
1. **Learning AI/ML** - Hands-on experimentation without cloud costs
2. **Privacy-Sensitive Applications** - Medical, financial, personal data
3. **Edge AI Deployment** - Robotics, IoT, embedded systems
4. **Prototyping** - Test ideas before scaling to cloud
5. **Offline AI** - Remote locations, secure environments

---

## Architecture & Components

### 1. Ollama (Model Server)

**Purpose**: Easy model management and inference  
**Location**: `/usr/local/bin/ollama`  
**Models Storage**: `~/.ollama/models`  
**Configuration**: `~/.ollama_env`

**Key Features**:
- Simple command-line interface
- Automatic model downloading from library
- REST API for application integration
- Optimized for CPU and ARM64

**Quick Start**:
```bash
# Start server
ollama serve

# Download a model
ollama pull phi3:mini

# Chat with the model
ollama run phi3:mini

# List installed models
ollama list
```

**Recommended Models for Pi 5**:
- `phi3:mini` (2.2GB) - Best overall quality/performance
- `llama3.2:1b` (1.3GB) - Fast, lightweight
- `qwen2.5:3b` (2GB) - Excellent multilingual
- `gemma2:2b` (1.6GB) - Google's efficient model

### 2. llama.cpp (Advanced Inference)

**Purpose**: High-performance inference and model conversion  
**Location**: `~/ai-tools/llama.cpp`  
**Binaries**: `~/ai-tools/llama.cpp/build/bin/`

**Key Tools**:
- `llama-cli` - Run GGUF models from command line
- `llama-quantize` - Convert and compress models
- `llama-server` - HTTP API server
- `llama-bench` - Performance benchmarking

**Usage Example**:
```bash
# Run a GGUF model
~/ai-tools/llama.cpp/build/bin/llama-cli \
  -m model.gguf \
  -p "Explain quantum computing" \
  -n 256

# Quantize a model (reduce size)
~/ai-tools/llama.cpp/build/bin/llama-quantize \
  input.gguf output-q4.gguf Q4_K_M

# Start inference server
~/ai-tools/llama.cpp/build/bin/llama-server \
  -m model.gguf \
  --host 127.0.0.1 \
  --port 8080
```

**Why llama.cpp?**
- Extremely efficient on ARM CPUs
- Supports quantization (4-bit, 8-bit)
- No Python dependencies
- Perfect for production deployment

### 3. Python AI Stack

**Purpose**: Fine-tuning and advanced ML workflows  
**Location**: `~/ai-tools/venv`  
**Configuration**: `~/.huggingface_env`

**Installed Libraries**:
- **PyTorch** - Deep learning framework
- **Transformers** - Hugging Face model library
- **PEFT** - Parameter-efficient fine-tuning (LoRA)
- **Datasets** - Data loading and processing
- **Accelerate** - Distributed training utilities
- **BitsAndBytes** - Quantization support

**Activate Environment**:
```bash
source ~/ai-tools/venv/bin/activate
# Or use the alias
ai-env
```

### 4. AI Helper Script

**Purpose**: Simplified system management  
**Location**: `~/ai-helper.sh`

**Available Commands**:
```bash
./ai-helper.sh status       # System health check
./ai-helper.sh start        # Start Ollama server
./ai-helper.sh stop         # Stop Ollama server
./ai-helper.sh models       # List models
./ai-helper.sh pull <name>  # Download model
./ai-helper.sh run <name>   # Interactive chat
./ai-helper.sh benchmark    # Performance test
./ai-helper.sh memory       # RAM usage
./ai-helper.sh temp         # CPU temperature
```

---

## Privacy & Security Architecture

All Smart Factory PiAI components are configured for **zero external data transfer**:

### Ollama Privacy Settings
```bash
OLLAMA_TELEMETRY=false           # No usage statistics
OLLAMA_ANALYTICS=false           # No analytics
OLLAMA_HOST=127.0.0.1:11434     # Localhost only
OLLAMA_AUTO_UPDATE=false         # No automatic updates
```

### Hugging Face Offline Mode
```bash
HF_HUB_OFFLINE=1                # Force offline operation
HF_HUB_DISABLE_TELEMETRY=1      # Disable telemetry
TRANSFORMERS_OFFLINE=1           # No model downloads
```

### Network Configuration
- All services bind to `127.0.0.1` (localhost only)
- No external API calls during inference
- Models downloaded once, cached locally
- No crash reporting or error telemetry

**Optional: Firewall Rules**
```bash
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
# Only allow local connections to AI services
```

---

## Common Workflows

### Workflow 1: Using Pre-Trained Models

**Step 1**: Download a model
```bash
./ai-helper.sh pull phi3:mini
```

**Step 2**: Start chatting
```bash
./ai-helper.sh run phi3:mini
```

**Step 3**: Use in your application (REST API)
```python
import requests

response = requests.post('http://localhost:11434/api/generate', 
    json={
        "model": "phi3:mini",
        "prompt": "Explain neural networks",
        "stream": False
    })

print(response.json()['response'])
```

### Workflow 2: Fine-Tuning with LoRA

**Step 1**: Prepare your dataset
```python
# dataset.jsonl format:
{"text": "Your training example 1"}
{"text": "Your training example 2"}
```

**Step 2**: Run fine-tuning
```bash
source ~/ai-tools/venv/bin/activate
python ~/ai-tools/finetune-example.py
```

**Step 3**: Convert to GGUF for Ollama
```bash
cd ~/ai-tools/llama.cpp
python convert_hf_to_gguf.py ./finetuned-model --outfile custom-model.gguf
```

**Step 4**: Create Ollama model
```bash
ollama create mymodel -f Modelfile
# Modelfile contains: FROM ./custom-model.gguf
```

### Workflow 3: Image Classification with Hailo

**Check Hailo Status**:
```bash
lsmod | grep hailo_pci
# Should show: hailo_pci module loaded
```

**Use Hailo for Vision Tasks**:
```bash
# Install Hailo Python API (if not already installed)
pip install hailort

# Run inference with Hailo acceleration
python your_vision_app.py
```

*Note: Hailo SDK and examples available at [hailo.ai/developer-zone](https://hailo.ai/developer-zone)*

### Workflow 4: Model Format Conversion

**Hugging Face → GGUF → Ollama**:
```bash
# 1. Download HF model (with internet, then go offline)
export HF_HUB_OFFLINE=0
python -c "from transformers import AutoModel; AutoModel.from_pretrained('microsoft/phi-2')"
export HF_HUB_OFFLINE=1

# 2. Convert to GGUF
cd ~/ai-tools/llama.cpp
python convert_hf_to_gguf.py ~/.cache/huggingface/hub/models--microsoft--phi-2 \
  --outfile phi2.gguf

# 3. Quantize (optional, reduces size)
./build/bin/llama-quantize phi2.gguf phi2-q4.gguf Q4_K_M

# 4. Import to Ollama
ollama create phi2:custom -f Modelfile
```

---

## Performance Optimization

### Memory Management
```bash
# Check available RAM
free -h

# Limit model context size
ollama run phi3:mini --ctx-size 2048

# Use quantized models (Q4_K_M recommended)
```

### CPU Optimization
```bash
# Check CPU temperature
vcgencmd measure_temp

# Monitor in real-time
watch -n 1 vcgencmd measure_temp

# Ensure active cooling is working
# Target: < 70°C under load
```

### Model Selection Tips
| RAM Available | Recommended Max Parameters | Example Models |
|---------------|---------------------------|----------------|
| 4-8 GB        | 1-3B                      | llama3.2:1b, phi3:mini |
| 8-16 GB       | 3-7B                      | phi3:mini, qwen2.5:3b |
| 16+ GB        | 7-13B (quantized)         | llama3.2:3b, phi3:medium |

### Quantization Guide
- **Q4_K_M**: Best quality/size balance (recommended)
- **Q4_K_S**: Smaller, slightly lower quality
- **Q5_K_M**: Higher quality, larger size
- **Q8_0**: Near-original quality, 2x larger

---

## Troubleshooting

### System Won't Boot
- Verify 27W power supply (inadequate power is #1 issue)
- Re-flash SD card with fresh OS
- Check for corrupted SD card

### AI HAT Not Detected
```bash
# Check kernel module
lsmod | grep hailo

# If missing, check firmware
sudo rpi-eeprom-update -a
sudo reboot

# Verify HAT is properly seated
# Power off, reseat, power on
```

### Out of Memory Errors
```bash
# Use smaller models
ollama pull llama3.2:1b

# Reduce context window
ollama run phi3:mini --ctx-size 1024

# Close other applications
# Check: htop or top
```

### Slow Performance
- Verify active cooling is working (check temp)
- Use quantized models (Q4_K_M)
- Reduce context size (`--ctx-size`)
- Try smaller models

### Installation Issues
```bash
# Re-run installation
cd ~/PiAI
./scripts/install.sh

# Check for disk space
df -h

# Verify internet connection during install
ping -c 3 google.com
```

---

## Fun Starter Projects

Ready to build something? Here are project ideas to get you started:

### 1. **Personal AI Assistant** 
Build a voice-activated assistant that runs entirely on your Pi.
- [Tutorial Repository](https://github.com/dougrichards13/PiAI-personal-assistant)
- Tech: Ollama + Whisper + text-to-speech
- Difficulty: Beginner

### 2. **Smart Home Object Detection**
Use your Pi as a security camera with AI-powered detection.
- [Tutorial Repository](https://github.com/dougrichards13/PiAI-object-detection)
- Tech: Hailo AI HAT + camera module
- Difficulty: Intermediate

### 3. **Custom Chatbot for Your Documents**
Create a chatbot that answers questions about your personal documents.
- [Tutorial Repository](https://github.com/dougrichards13/PiAI-rag-chatbot)
- Tech: Ollama + RAG (Retrieval Augmented Generation)
- Difficulty: Intermediate

### 4. **Fine-Tune Your Own Model**
Train an AI on your own writing style or domain knowledge.
- [Tutorial Repository](https://github.com/dougrichards13/PiAI-fine-tuning)
- Tech: Python + PEFT/LoRA
- Difficulty: Advanced

### 5. **Raspberry Pi Cluster AI**
Connect multiple Pi 5s for distributed inference.
- [Tutorial Repository](https://github.com/dougrichards13/PiAI-cluster)
- Tech: Multiple Pi 5s + distributed computing
- Difficulty: Advanced

---

## Community Resources

### Get Help
- **Smart Factory Community**: [smartfactory.io/community](https://smartfactory.io/community)
- **GitHub Discussions**: [PiAI Discussions](https://github.com/dougrichards13/PiAI/discussions)
- **GitHub Issues**: [Report bugs or request features](https://github.com/dougrichards13/PiAI/issues)

### Share Your Projects
- **Project Showcase**: [smartfactory.io/showcase](https://smartfactory.io/showcase)
- **Social Media**: Tag **@SmartFactoryIO**
- **Contribute**: Submit PRs to improve this project

### Additional Learning
- **Ollama Library**: [ollama.com/library](https://ollama.com/library)
- **llama.cpp Documentation**: [github.com/ggerganov/llama.cpp](https://github.com/ggerganov/llama.cpp)
- **Hugging Face Docs**: [huggingface.co/docs](https://huggingface.co/docs)
- **Raspberry Pi AI HAT**: [raspberrypi.com/documentation](https://www.raspberrypi.com/documentation/accessories/ai-hat-plus.html)
- **Hailo Developer Zone**: [hailo.ai/developer-zone](https://hailo.ai/developer-zone)

---

## Advanced Topics

### Using Multiple Models Simultaneously
```bash
# Start Ollama server
ollama serve &

# Start llama.cpp server on different port
~/ai-tools/llama.cpp/build/bin/llama-server \
  -m model.gguf --port 8081 &

# Now you can use both via their APIs
```

### GPU Acceleration (Future)
While the Pi 5 doesn't have traditional GPU support, the Hailo AI HAT provides NPU acceleration. Future updates may include:
- Hailo model optimization tools
- Custom quantization for Hailo
- Vision transformer support

### Battery-Powered Operation
For portable AI applications:
- Use USB-C PD battery pack (27W minimum)
- Enable power management: `sudo raspi-config` → Performance → Power
- Monitor power: `vcgencmd get_throttled`

---

## Quick Reference

### Essential Commands
```bash
# System status
./ai-helper.sh status

# Model management
ollama list                    # List models
ollama pull <name>            # Download
ollama rm <name>              # Remove
ollama run <name>             # Chat

# Performance
vcgencmd measure_temp         # Temperature
free -h                       # Memory
htop                          # Resource monitor

# Maintenance
sudo apt update && sudo apt upgrade -y    # System updates
pip list --outdated                       # Python package updates
```

### File Locations
- **Ollama models**: `~/.ollama/models/`
- **HuggingFace cache**: `~/.cache/huggingface/`
- **Python environment**: `~/ai-tools/venv/`
- **llama.cpp**: `~/ai-tools/llama.cpp/`
- **Scripts**: `~/PiAI/scripts/`
- **Examples**: `~/PiAI/examples/`

---

## Contributing

We welcome contributions! Whether you:
- Found a bug
- Have a feature request
- Want to improve documentation
- Built something cool you want to share

**Please contribute!**

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

See [CONTRIBUTING.md](../CONTRIBUTING.md) for detailed guidelines.

---

## License

This project is released under the **MIT License** - free for anyone to use, modify, and distribute.

See [LICENSE](../LICENSE) for full details.

---

## About Smart Factory

[Smart Factory](https://smartfactory.io) is pioneering the future of intelligent manufacturing and edge AI. Our mission is to democratize AI technology, making it accessible, private, and practical for real-world applications.

This project demonstrates our expertise in:
- Edge AI deployment
- Privacy-preserving ML systems
- Production-ready AI infrastructure
- Developer-friendly tooling

**Interested in Smart Factory solutions for your business?**  
Contact us: [smartfactory.io/contact](https://smartfactory.io/contact)

---

## Acknowledgments

- **Raspberry Pi Foundation** - For creating amazing hardware
- **Ollama Team** - For making AI accessible
- **llama.cpp Contributors** - For incredible optimization work
- **Hugging Face** - For the transformers ecosystem
- **Hailo** - For AI acceleration hardware
- **Open Source Community** - For making this all possible

---

**Project Author**: Doug Richards, Executive Chairman, Smart Factory  
**Last Updated**: November 2025  
**Version**: 1.0  
**Privacy Status**: ✅ 100% Local, No External Data Sharing

---

*Ready to get started? Head to the [JumpStart Guide](JumpStart.md) for step-by-step setup instructions!*
