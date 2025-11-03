# JumpStart Guide: Setting Up Your Raspberry Pi 5 for AI

Welcome! This guide will walk you through **every step** needed to set up your Raspberry Pi 5 for AI experimentation—even if you've never used a Raspberry Pi before.

---

## What You'll Need

### Required Hardware
- **Raspberry Pi 5** (8GB or 16GB RAM recommended)
- **Raspberry Pi AI HAT+** or **Hailo-8L AI Accelerator**
  - Purchase: [Raspberry Pi Official Store](https://www.raspberrypi.com/products/ai-hat/)
- **microSD Card** (32GB or larger, Class 10 or better)
- **USB-C Power Supply** (27W official Raspberry Pi power supply recommended)
- **MicroHDMI to HDMI Cable** (for connecting to monitor)
- **Keyboard and Mouse** (USB or wireless)
- **Monitor or TV** (with HDMI input)

### Optional but Recommended
- **Active cooling fan** (keeps Pi cool during AI workloads)
- **Case** (protects your Pi)
- **Ethernet cable** (for more stable internet during setup)

---

## Step 1: Download Raspberry Pi OS

We recommend **Raspberry Pi OS (64-bit)** for best AI performance.

1. **Download Raspberry Pi Imager**
   - Windows/Mac/Linux: [https://www.raspberrypi.com/software/](https://www.raspberrypi.com/software/)
   
2. **Install and open** Raspberry Pi Imager

---

## Step 2: Prepare Your microSD Card

1. **Insert your microSD card** into your computer (use an adapter if needed)

2. **In Raspberry Pi Imager:**
   - Click **"Choose Device"** → Select **Raspberry Pi 5**
   - Click **"Choose OS"** → Select **Raspberry Pi OS (64-bit)**
     - Find it under: *Raspberry Pi OS (other)* → *Raspberry Pi OS (64-bit)*
   - Click **"Choose Storage"** → Select your microSD card
   
3. **IMPORTANT: Configure Settings**
   - Click the **gear icon** (⚙️) or "Edit Settings" button
   - Set a **hostname** (e.g., `piai`)
   - **Enable SSH** (check "Enable SSH")
   - Set a **username** (e.g., `pi`) and **password** (remember this!)
   - Configure **Wi-Fi** (enter your network name and password)
   - Set your **timezone** and **keyboard layout**
   - Click **"Save"**

4. **Write to SD card**
   - Click **"Write"**
   - Wait 5-10 minutes for the process to complete
   - When done, **safely eject** the microSD card

---

## Step 3: Assemble Your Raspberry Pi 5

1. **Remove Pi from packaging** (handle by edges to avoid static damage)

2. **Attach the AI HAT+** (if you have one)
   - Align the HAT's 40-pin connector with the GPIO pins on the Pi
   - Gently press down until fully seated
   - Secure with standoffs/screws if provided

3. **Insert the microSD card**
   - Insert into the microSD slot on the bottom of the Pi
   - Push gently until it clicks

4. **Connect peripherals**
   - Plug in keyboard and mouse (USB ports)
   - Connect monitor (microHDMI port—usually the one closest to the USB-C power)
   - Connect Ethernet cable (optional but recommended for first boot)

5. **Power up**
   - **Last step:** Connect USB-C power supply
   - Your Pi should boot automatically (green LED will blink)

---

## Step 4: First Boot Setup

1. **Wait for boot** (30-60 seconds on first boot)
   
2. **Welcome screen will appear**
   - Follow the on-screen setup wizard
   - If you configured Wi-Fi in Step 2, it should connect automatically
   - Complete any remaining setup steps

3. **Update your system** (IMPORTANT!)
   - Open **Terminal** (black icon at top of screen)
   - Run these commands:
   ```bash
   sudo apt update
   sudo apt upgrade -y
   ```
   - This may take 10-20 minutes—be patient!
   - Reboot when complete: `sudo reboot`

---

## Step 5: Verify AI HAT Installation

After rebooting, verify your AI HAT is detected:

1. **Open Terminal**

2. **Check for Hailo module:**
   ```bash
   lsmod | grep hailo
   ```
   - You should see `hailo_pci` in the output
   - If not, check HAT is properly seated or consult [Raspberry Pi AI HAT docs](https://www.raspberrypi.com/documentation/accessories/ai-hat-plus.html)

3. **Check system info:**
   ```bash
   uname -m
   ```
   - Should show: `aarch64` (64-bit ARM)

---

## Step 6: Install PiAI Software

Now you're ready to install the Smart Factory PiAI AI tools!

1. **Clone the PiAI repository:**
   ```bash
   cd ~
   git clone https://github.com/dougrichards13/PiAI.git
   cd PiAI
   ```

2. **Run the automated installation script:**
   ```bash
   chmod +x scripts/install.sh
   ./scripts/install.sh
   ```
   - This script will install:
     - Ollama (AI model server)
     - llama.cpp (model conversion tools)
     - Python AI libraries (PyTorch, Transformers, etc.)
     - Privacy-focused configurations
   - Installation takes 20-40 minutes depending on your internet speed

3. **Follow the on-screen prompts**
   - The installer will guide you through each step
   - When complete, you'll see: ✅ **PiAI Installation Complete!**

---

## Step 7: Test Your Setup

Let's make sure everything works!

1. **Check system status:**
   ```bash
   ./ai-helper.sh status
   ```
   - Should show all components as "Running" or "Installed"

2. **Download your first AI model:**
   ```bash
   ./ai-helper.sh pull phi3:mini
   ```
   - Downloads a 2.2GB AI model (takes 5-10 minutes)

3. **Chat with the AI:**
   ```bash
   ./ai-helper.sh run phi3:mini
   ```
   - Try asking: "What is a Raspberry Pi?"
   - Type `/bye` to exit

---

## Step 8: Explore & Learn

Congratulations! Your PiAI is ready. Here's what to do next:

### Learn More
- **[Smart Factory PiAI Guide](../Smart_Factory_PiAI.md)** - Complete reference documentation
- **[Example Projects](../examples/)** - Fun projects to get started

### Suggested First Projects
1. **[Personal AI Assistant](../examples/personal-assistant/)** - Voice-controlled AI
2. **[Image Classifier](../examples/image-classifier/)** - Identify objects in photos
3. **[Fine-tune Your Own Model](../examples/fine-tuning/)** - Customize AI for your needs

### Quick Commands
```bash
./ai-helper.sh help        # See all available commands
./ai-helper.sh models      # List installed AI models
./ai-helper.sh pull <name> # Download new models
./ai-helper.sh run <name>  # Chat with a model
```

---

## Troubleshooting

### Pi won't boot
- Check power supply (needs 27W for Pi 5)
- Re-flash microSD card
- Try different microSD card

### AI HAT not detected
- Power off, reseat HAT, power on
- Check for bent pins on GPIO connector
- Update firmware: `sudo rpi-eeprom-update -a`

### Out of memory errors
- Use smaller models (phi3:mini, llama3.2:1b)
- Close other applications
- Consider upgrading to 16GB Pi 5

### Installation fails
- Check internet connection
- Re-run: `./scripts/install.sh`
- See [Smart Factory PiAI Guide](../Smart_Factory_PiAI.md) for manual installation

### Need help?
- [Smart Factory Community Forum](https://smartfactory.io/community)
- [GitHub Issues](https://github.com/dougrichards13/PiAI/issues)
- [Raspberry Pi Forums](https://forums.raspberrypi.com/)

---

## Privacy & Security

Your PiAI is configured for **100% local operation**:
- ✅ All AI processing happens on your device
- ✅ No data sent to external servers
- ✅ All telemetry disabled
- ✅ Your conversations stay private

---

## Next Steps

Once you're comfortable with the basics:
1. **Experiment with different models** - Try llama3.2, qwen2.5, gemma2
2. **Build a project** - Check out our [example projects](../examples/)
3. **Fine-tune a model** - Make AI do exactly what you want
4. **Share your creation** - Submit to [Smart Factory showcase](https://smartfactory.io/showcase)

---

**Welcome to the PiAI community!** 🎉

If you create something cool, share it with us:
- Tag **@SmartFactoryIO** on social media
- Submit projects to [showcase](https://smartfactory.io/showcase)
- Contribute to this repo on [GitHub](https://github.com/dougrichards13/PiAI)

---

*Project by [Smart Factory](https://smartfactory.io) | Author: Doug Richards, Executive Chairman*
