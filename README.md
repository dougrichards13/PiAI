# 🤖 Smart Factory PiAI

**Transform Your Raspberry Pi 5 into a Privacy-Focused AI Powerhouse**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Raspberry Pi 5](https://img.shields.io/badge/Raspberry%20Pi-5-C51A4A)](https://www.raspberrypi.com/products/raspberry-pi-5/)
[![AI HAT+](https://img.shields.io/badge/AI%20HAT+-Hailo--8L-blue)](https://www.raspberrypi.com/products/ai-hat/)

*A production-ready AI toolkit for the Raspberry Pi 5, brought to you by [Smart Factory](https://smartfactory.io)*

**UPDATE (November 2025):** Initial testing successful on Raspberry Pi 5 (8GB). Installation script validated and working. We're now expanding hardware testing - if you try this on different hardware (Pi 4, other ARM64 systems), please share your results in [Discussions](https://github.com/dougrichards13/PiAI/discussions)!

---

## 🆕 What's New in v0.14 (Latest Release)

**Released:** November 2025 | **Status:** Beta - Validated on Pi 5 (8GB)

This release marks the first validated installation on Raspberry Pi 5 with significant enhancements to installation reliability and system diagnostics.

### Key Improvements

✨ **New System Diagnostic Tool** - `system-tune.sh`
- Full system diagnostics and health checks
- Performance optimization (CPU governor, GPU memory)
- Integrated benchmarking tools
- Run with: `~/system-tune.sh diagnose`

🛡️ **Enhanced Installation Safety**
- **Disk space check** - Validates 20GB minimum before starting
- **Temperature monitoring** - Warns if system is hot (>75°C) before install
- **Smart error recovery** - Automatically cleans partial builds if llama.cpp fails
- **Better progress tracking** - Temperature checks during intensive operations

🔧 **Configuration Improvements**
- HuggingFace offline mode now **disabled by default** (allows initial model downloads)
- Clear instructions in config files for enabling full offline mode later
- Improved error messages throughout installation

📋 **Testing Status**
- ✅ Validated on Raspberry Pi 5 (8GB RAM) with Hailo AI HAT+
- ✅ All components install successfully (Ollama, llama.cpp, PyTorch stack)
- ✅ System runs stable at 80-85°C during installation
- ✅ Helper scripts functional and working

👉 **[View Full Release Notes](RELEASE_NOTES_v0.14.md)** | **[Download v0.14](https://github.com/dougrichards13/PiAI/releases/tag/v0.14)**

---

## 🎯 What is PiAI?

**Smart Factory PiAI** is a comprehensive, privacy-first AI development environment for the Raspberry Pi 5. We've "resurfaced" the Pi—optimizing it specifically for running, experimenting with, and fine-tuning AI models entirely on-device.

DISCLAIMER: This project is an experiment. This project is also not groundbreaking, there are literally dozens of Pi gurus on YouTube like the infamous Jeff Geerling @JeffGeerling, Network Chuck @NetworkChuck, Data Slayer @dataslayermedia, MichaelKlements @MichaelKelments, the team at @CoreElectronics and so many more. This particular project is a bit self-serving since I wanted a way to easily resurface a Pi 5 with an AI top for my own tests and pet projects. I also really enjoy documenting projects like this so - yes, it is overkill but hey, I had fun building it! (Doug Richards)

### Why PiAI?

✅ **100% Local** - All AI processing on your device, zero cloud dependency  
✅ **Privacy-First** - No telemetry, no data collection, no external calls  
✅ **Beginner-Friendly** - Clear guides for all skill levels  
✅ **Production-Ready** - Battle-tested tools: Ollama, llama.cpp, PyTorch  
✅ **Fine-Tuning Ready** - LoRA/PEFT support for custom models  
✅ **Free & Open Source** - MIT licensed, use however you want  

---

## 🚀 Quick Start

### For Complete Beginners

**Never used a Raspberry Pi before?** Start here:

👉 **[JumpStart Guide](docs/JumpStart.md)** - Step-by-step setup from scratch

This guide covers:
- Choosing the right hardware
- Installing Raspberry Pi OS
- Setting up the AI HAT
- Running your first AI model

### For Experienced Users

**Already have a Pi 5 running?** Jump right in:

```bash
# Clone the repository
cd ~
git clone https://github.com/dougrichards13/PiAI.git
cd PiAI

# Run the automated installer
chmod +x scripts/install.sh
./scripts/install.sh

# Test your setup
~/ai-helper.sh status
~/system-tune.sh diagnose  # Optional: detailed system diagnostics
~/ai-helper.sh pull phi3:mini
~/ai-helper.sh run phi3:mini
```

Installation takes 20-40 minutes depending on your internet speed.

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **[JumpStart Guide](docs/JumpStart.md)** | Complete beginner's setup guide |
| **[Smart Factory PiAI Reference](docs/Smart_Factory_PiAI.md)** | Comprehensive technical documentation |
| **[Example Projects](examples/)** | Fun projects to get started |
| **[Contributing](CONTRIBUTING.md)** | How to contribute to this project |

---

## 💡 What Can You Build?

As mentioned above, there are so many cool projects you can build with a PiAI machine. Some are practical like a video doorbell or a smarter version of a Pihole. I strongly recommend looking at the YouTube channels and their project repos and hubs for inspiration and fun. Here are some of the tings I am working on. Links will be updated when the projects get are beta-ready.

### Future Projects

1. **[Personal AI Assistant](https://github.com/dougrichards13/PiAI-personal-assistant)** *(Coming Soon)*  
   Voice-controlled AI that runs entirely on your Pi. There are a lot of cool things you can do with voice on a Pi and plenty of open-source libraries to support the build. We are currently looking at how to potentially offline the model and employ user patterns (via voice and gamification) to truly personlize the assistant in a meaningful way - in other words, no one needs another weather bot or personal shopper.
   
2. **[Smart Camera with Object Detection] ** *(Coming Soon)*  
   Real-time object detection using the Hailo AI HAT. 

   If you've tried the Pi AI Camera you'll know that this is already out of the box functionality. The Lab is working on training to specific scenarios - for example pairing PiAI with IoT and edge devices for alerts in physical spaces
   
3. **[Document Q&A Chatbot]** *(Coming Soon)*  
   Answer questions about your personal documents. This is actually built, we just need to test the security and privacy more throughly. This project will be a vertical agent that runs invisibly as a subset of the Assistant suite. 
   
4. **[Custom Model Fine-Tuning](https://github.com/dougrichards13/PiAI-fine-tuning)** *(Coming Soon)*  
   Train AI on your writing style or domain knowledge.

   Again, this is already part of several popular LLMs but, the gap is how to correct the model easily via the interface verbablly/input versus programatically.

---

## ⚙️ What's Included

### Software Stack

- **[Ollama](https://ollama.com/)** - Simple AI model management and serving
- **[llama.cpp](https://github.com/ggerganov/llama.cpp)** - High-performance inference engine
- **PyTorch** - Deep learning framework
- **Transformers** - Hugging Face model library
- **PEFT** - Parameter-efficient fine-tuning (LoRA)
- **Helper Scripts** - Easy system management and diagnostics
  - `ai-helper.sh` - AI model management
  - `system-tune.sh` - System diagnostics and performance tuning

### Hardware Requirements

**Minimum:**
- Raspberry Pi 5 (8GB RAM)
- 32GB microSD card
- 27W USB-C power supply

**Recommended:**
- Raspberry Pi 5 (16GB RAM)
- Raspberry Pi AI HAT+ (Hailo-8L)
- 64GB+ microSD card (Class 10, A2)
- Active cooling solution
- 27W official power supply

### Supported Models

| Model | Size | Speed | Use Case |
|-------|------|-------|----------|
| `phi3:mini` | 2.2GB | ⭐⭐⭐⭐ | Best overall quality |
| `llama3.2:1b` | 1.3GB | ⭐⭐⭐⭐⭐ | Fastest, lightweight |
| `qwen2.5:3b` | 2GB | ⭐⭐⭐⭐ | Multilingual support |
| `gemma2:2b` | 1.6GB | ⭐⭐⭐⭐ | Google's efficient model |

*See [full model list](docs/Smart_Factory_PiAI.md#recommended-models) in documentation*

---

## 🎓 Learn More

### Realistic Expectations

**What works well:**
- Text generation & chatbots (2-10 tokens/sec)
- Image classification with Hailo acceleration
- Fine-tuning small models with LoRA
- Offline, privacy-sensitive applications

**Limitations:**
- Not as fast as cloud GPUs
- Large models (13B+) may be too slow
- Fine-tuning large models takes days

**Sweet spot:** Learning, prototyping, privacy applications, edge deployment

*Full performance guide: [Smart Factory PiAI Reference](docs/Smart_Factory_PiAI.md)*

---

## 🔒 Privacy & Security

Your PiAI is configured for **complete privacy**:

- ✅ All AI processing happens locally
- ✅ Zero telemetry or analytics
- ✅ No automatic updates or external calls
- ✅ Models cached locally after download
- ✅ Localhost-only service bindings

**Your data never leaves your device.**

---

## 🤝 Community & Support

### Get Help

- **[GitHub Discussions](https://github.com/dougrichards13/PiAI/discussions)** - Ask questions, share ideas
- **[GitHub Issues](https://github.com/dougrichards13/PiAI/issues)** - Report bugs or request features
- **[Smart Factory Community](https://smartfactory.io/community)** - Join our community forum

### Share Your Projects

Built something cool? We'd love to see it!

- **[Project Showcase](https://smartfactory.io/showcase)** - Submit your projects
- **Social Media** - Tag `@SmartFactoryIO`
- **Contribute** - Submit PRs to improve PiAI

---

## 🏭 About Smart Factory

[**Smart Factory**](https://smartfactory.io) is pioneering the future of human/machine work with our AI Synthesizer workforce. This project and the other open-book Lab projects demonstrates our expertise in privacy-preserving AI systems and production-ready edge deployments.

**Our Mission:** Democratize AI technology—making it accessible, private, and practical for real-world applications.

### Why We Built This

We believe AI should be:
- **Accessible** - Anyone can run powerful AI on affordable hardware
- **Private** - Your data belongs to you, not in the cloud
- **Practical** - Real solutions for real problems
- **Fun** - AI is amazingly powerful and fun to work with and should be available to all levels of technical users

**Interested in Smart Factory for your business?**  
[Visit](https://smartfactory.io) to learn about our enterprise AI solutions.

---

## 👥 Credits

**Project Author:** Doug Richards, Executive Chairman, Smart Factory  
**License:** MIT (free for any use)  
**Version:** 0.14 (beta) 
**Last Updated:** November 11, 2025

### Changelog

**v0.14 (November 2025)**
- ✅ Validated installation on Raspberry Pi 5 (8GB)
- Added disk space check (20GB minimum)
- Added temperature monitoring during install
- Improved error recovery for llama.cpp builds
- Modified HuggingFace offline mode (disabled by default for initial setup)
- Enhanced system diagnostics

**v0.13 (November 2025)**
- Initial release

### Acknowledgments

- **Raspberry Pi Foundation** - Amazing hardware
- **Ollama Team** - Making AI accessible
- **llama.cpp Contributors** - Incredible optimization
- **Hugging Face** - Transformers ecosystem
- **Hailo** - AI acceleration hardware
- **Open Source Community** - Making it all possible

---

## 📜 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

**TL;DR:** Use it however you want, commercially or personally, with attribution.

---

## ⭐ Star This Project

If you find PiAI useful, please **star this repository** to help others discover it!

---

## 🚦 Getting Started Checklist

- [ ] Read the [JumpStart Guide](docs/JumpStart.md)
- [ ] Set up your Raspberry Pi 5 with AI HAT
- [ ] Run the installation script
- [ ] Download your first model (`phi3:mini`)
- [ ] Chat with AI locally
- [ ] Explore [example projects](examples/)
- [ ] Share your creation with the community

---

**Ready to begin?** 👉 [Start with the JumpStart Guide](docs/JumpStart.md)

**Questions?** 👉 [GitHub Discussions](https://github.com/dougrichards13/PiAI/discussions)

**Need the full reference?** 👉 [Smart Factory PiAI Guide](docs/Smart_Factory_PiAI.md)

---

*Made with ❤️ by [Smart Factory](https://smartfactory.io) - Empowering the future of edge AI*
