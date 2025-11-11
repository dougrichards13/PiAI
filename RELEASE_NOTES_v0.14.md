# PiAI v0.14 Release Notes

**Release Date:** November 2025  
**Status:** Beta - Validated on Raspberry Pi 5 (8GB)

---

## 🎉 What's New

### Installation Enhancements

1. **Disk Space Check**
   - Installation now requires 20GB minimum free space
   - Pre-install validation prevents incomplete installations

2. **Temperature Monitoring**
   - Checks system temperature before install (warns if >75°C)
   - Monitors temperature during intensive build steps
   - Helps prevent thermal throttling issues

3. **Improved Error Recovery**
   - llama.cpp builds now clean partial builds automatically
   - Better error messages with recovery suggestions
   - Failed builds won't corrupt future attempts

4. **HuggingFace Offline Mode**
   - Now disabled by default to allow initial model downloads
   - Users can enable full offline mode after setup
   - Clear instructions in config file

### New System Diagnostic Tool

**`system-tune.sh`** - Comprehensive system management utility:

```bash
~/system-tune.sh diagnose     # Full system diagnostics
~/system-tune.sh healthcheck  # Quick health check
~/system-tune.sh optimize     # Apply performance optimizations
~/system-tune.sh benchmark    # Run performance tests
~/system-tune.sh restore      # Restore default settings
```

#### Features:
- Hardware info (CPU, RAM, disk, temperature)
- Software status (Ollama, Hailo, Python, llama.cpp)
- Model storage analysis
- Performance analysis (CPU governor, swap, thermals)
- System optimization (CPU performance mode, GPU memory)
- Benchmarking tools

### Documentation Updates

- Removed beta warning - installation validated
- Added changelog section
- Updated troubleshooting with new features
- Added system-tune.sh usage examples

---

## 🧪 Testing Status

### Validated Configurations

✅ **Raspberry Pi 5 (8GB RAM)**
- Debian GNU/Linux (Bookworm)
- ARM64 (aarch64) architecture
- Hailo AI HAT+ loaded
- All components installed successfully
- Ollama server running
- llama.cpp built successfully

### Known Working Components

- Ollama installation and configuration
- llama.cpp compilation (with CURL disabled)
- Python virtual environment with full AI stack:
  - PyTorch
  - Transformers
  - Datasets
  - Accelerate
  - PEFT
  - bitsandbytes
- Privacy configuration (telemetry disabled)
- AI helper scripts

### Temperature Notes

During installation, system temperature may reach 80-85°C during:
- llama.cpp compilation (10-15 minutes)
- Python package installation (15-20 minutes)

**Recommendation:** Ensure adequate cooling (active fan recommended) before running installation.

---

## 🔄 Changes from v0.13

### Installation Script (`install.sh`)

**Added:**
- `check_system()` - Disk space validation (20GB minimum)
- `check_system()` - Temperature check with user prompt if >75°C
- `build_llama_cpp()` - Automatic cleanup of partial builds
- `monitor_temperature()` - Temperature monitoring function
- `setup_helper_script()` - Now installs both ai-helper.sh and system-tune.sh

**Modified:**
- `setup_huggingface_privacy()` - Offline mode disabled by default with instructions
- Error messages improved throughout
- Install completion message includes new system-tune.sh command

### New Files

- `scripts/system-tune.sh` - System diagnostic and optimization utility
- `RELEASE_NOTES_v0.14.md` - This file

### Documentation Updates

- `README.md` - Beta notice replaced with testing update, version bumped, changelog added
- `docs/JumpStart.md` - Troubleshooting section updated with new checks
- Quick start examples updated to include system-tune.sh

---

## 🐛 Known Issues

None currently reported. This is the first validated release.

---

## 🚀 Testing Checklist for Other Hardware

If you're testing PiAI v0.14 on different hardware, please verify:

- [ ] Architecture check passes (ARM64 required)
- [ ] Disk space check (20GB+ free)
- [ ] All dependencies install successfully
- [ ] Ollama installs and starts
- [ ] llama.cpp builds without errors
- [ ] Python environment creates successfully
- [ ] All Python packages install (especially PyTorch)
- [ ] Ollama server starts automatically
- [ ] Helper scripts are executable and work
- [ ] `ai-helper.sh status` shows all components
- [ ] Temperature monitoring works (if vcgencmd available)
- [ ] Can pull and run a test model (phi3:mini recommended)

### Report Results

Please share your testing results in [GitHub Discussions](https://github.com/dougrichards13/PiAI/discussions) with:
- Hardware details (Pi model, RAM, any HATs)
- OS version (`cat /etc/os-release`)
- Success/failure status
- Any error messages encountered
- Temperature readings during install
- Performance notes

---

## 🎯 Next Steps

After installing v0.14:

1. **Run diagnostics:**
   ```bash
   ~/system-tune.sh diagnose
   ```

2. **Check health:**
   ```bash
   ~/system-tune.sh healthcheck
   ```

3. **Optimize for AI (optional):**
   ```bash
   ~/system-tune.sh optimize
   ```

4. **Download your first model:**
   ```bash
   ~/ai-helper.sh pull phi3:mini
   ```

5. **Start building!**

---

## 🙏 Credits

Thanks to everyone testing and providing feedback. Special recognition to:
- The Raspberry Pi Foundation for amazing hardware
- Ollama team for making AI accessible
- llama.cpp contributors for optimization wizardry
- The open source community for making this possible

---

## 📞 Support

- **Questions:** [GitHub Discussions](https://github.com/dougrichards13/PiAI/discussions)
- **Bugs:** [GitHub Issues](https://github.com/dougrichards13/PiAI/issues)
- **Community:** [Smart Factory Forum](https://smartfactory.io/community)

---

**Author:** Doug Richards, Executive Chairman, Smart Factory  
**License:** MIT (free for any use)  
**Project:** [github.com/dougrichards13/PiAI](https://github.com/dougrichards13/PiAI)
