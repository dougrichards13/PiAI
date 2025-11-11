# 🎤 PiAI Personal Assistant - "Hello Doug"

A **100% local, privacy-first voice assistant** for Raspberry Pi 5. No cloud services. No data sharing. No subscriptions. Completely open source.

Built by Doug Richards for PiAI as a demonstration of truly private AI at the edge.

---

## 🎯 What It Does

This is a personalized voice assistant that:

- ✅ **Listens for wake word** ("Hey Pi") - fully local with openWakeWord
- ✅ **Understands your speech** - local Whisper model (no cloud API)
- ✅ **Responds intelligently** - using Ollama LLM running on your Pi
- ✅ **Speaks back to you** - local text-to-speech (Piper or eSpeak)
- ✅ **Gives morning weather** - privacy-friendly weather service (wttr.in)
- ✅ **Personalized for you** - knows your name, learns preferences

**Your conversations never leave your Pi.** Everything runs locally.

---

## 🔒 Privacy Architecture

Unlike Alexa, Google Home, or Siri, this assistant:

- **No cloud processing** - All AI runs on your Raspberry Pi 5
- **No wake word tracking** - openWakeWord runs 100% offline
- **No speech sent to servers** - Whisper transcribes locally
- **No conversation logging** - Your data stays on your device
- **No subscriptions or accounts** - Completely free and open
- **No telemetry** - Zero tracking or analytics

**What makes this different from popular Pi voice assistant projects:**
- Most tutorials use cloud APIs (Google Speech, OpenAI, AWS)
- This uses **only local models** - inspired by privacy-first Pi builders but taken further
- Weather service (wttr.in) is privacy-respecting with no API keys or tracking

---

## 🚀 Quick Start

### Prerequisites

1. **PiAI installed** - Follow the [main PiAI installation](../../README.md)
2. **Ollama model downloaded**:
   ```bash
   ~/ai-helper.sh pull phi3:mini
   ```
3. **USB microphone connected** (already detected on your Pi)
4. **Speakers or headphones** for audio output

### Installation

```bash
cd ~/PiAI/examples/personal-assistant

# Install system dependencies
sudo apt install -y portaudio19-dev espeak ffmpeg

# Install Python dependencies in PiAI venv
source ~/ai-tools/venv/bin/activate
pip install -r requirements.txt

# Make executable
chmod +x assistant.py
```

### First Run

```bash
# Activate PiAI environment
source ~/ai-tools/venv/bin/activate

# Make sure Ollama is running
~/ai-helper.sh status

# Run the assistant
./assistant.py
```

---

## 💬 Usage

### Basic Commands

1. **Wake the assistant**:
   - Say: **"Hey Pi"**
   - Or press **Enter** (if wake word detection isn't available)

2. **Ask questions or give commands**:
   - "What's the weather today?"
   - "Tell me about Raspberry Pi"
   - "What time is it?"
   - "Help me understand quantum computing"

3. **Morning greeting**:
   - Say: **"Good morning"** or **"Hello"**
   - Gets personalized greeting with weather

4. **Exit**:
   - Press **Ctrl+C**

### Personalization

Edit your config file to customize:
```bash
nano ~/.piai_assistant_config.json
```

```json
{
  "user_name": "Doug",
  "location": "San Francisco",  // Add your city for weather
  "preferences": {
    "morning_greeting": true,
    "weather_in_greeting": true
  }
}
```

---

## 🛠️ How It Works

### Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Raspberry Pi 5                     │
├─────────────────────────────────────────────────────┤
│                                                      │
│  🎤 USB Microphone                                   │
│      ↓                                               │
│  👂 Wake Word (openWakeWord) ────── LOCAL           │
│      ↓                                               │
│  🗣️ Speech-to-Text (Whisper) ──────── LOCAL         │
│      ↓                                               │
│  🧠 LLM Response (Ollama) ─────────── LOCAL          │
│      ↓                                               │
│  🔊 Text-to-Speech (Piper/eSpeak) ── LOCAL          │
│      ↓                                               │
│  🔈 Speakers/Headphones                              │
│                                                      │
│  🌤️ Weather (wttr.in) ──────────────── HTTPS ONLY  │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### Components

1. **Wake Word Detection**: [openWakeWord](https://github.com/dscripka/openWakeWord)
   - Fully open source, Apache 2.0 license
   - Runs entirely on device
   - No cloud, no telemetry

2. **Speech Recognition**: [OpenAI Whisper](https://github.com/openai/whisper)
   - State-of-the-art accuracy
   - Runs locally on Pi 5
   - Using "base" model for speed

3. **Language Model**: [Ollama](https://ollama.com/)
   - Local LLM server
   - phi3:mini recommended (2.2GB, fast on Pi 5)
   - No internet required after download

4. **Text-to-Speech**:
   - **Piper TTS** (preferred): High-quality, natural voice
   - **eSpeak** (fallback): Fast, robotic but reliable

5. **Weather**: [wttr.in](https://wttr.in/)
   - Privacy-friendly service
   - No API key required
   - No tracking or user accounts

---

## 🎨 Customization Ideas

### 1. Change Wake Word

Edit `assistant.py` line 46:
```python
self.wake_word = "hey_pi"  # Try: "alexa", "computer", etc.
```

Available wake words: https://github.com/dscripka/openWakeWord#pre-trained-models

### 2. Adjust Response Length

Edit line 257:
```python
"num_predict": 150  # Increase for longer responses
```

### 3. Add Custom Commands

Add to `get_response()` method:
```python
if "tell me a joke" in user_input.lower():
    return "Why did the Pi cross the road? To get to the other side... of the network!"
```

### 4. Change Voice Model

For Piper TTS, download other voices:
- https://github.com/rhasspy/piper/blob/master/VOICES.md

### 5. Install Better TTS (Optional)

```bash
# Install Piper for high-quality voice
wget https://github.com/rhasspy/piper/releases/latest/download/piper_linux_aarch64.tar.gz
tar -xzf piper_linux_aarch64.tar.gz
sudo mv piper/piper /usr/local/bin/
```

---

## 🐛 Troubleshooting

### Wake word not detecting

**Issue**: Not responding to "Hey Pi"

**Solutions**:
1. Check microphone: `arecord -l`
2. Adjust sensitivity in code (line 167): Lower threshold from 0.5 to 0.3
3. Fallback: Press Enter instead of speaking

### Whisper is slow

**Issue**: Speech recognition takes too long

**Solutions**:
1. Use "tiny" model instead of "base" (line 188):
   ```python
   text = self.recognizer.recognize_whisper(audio, model="tiny")
   ```
2. Ensure you have adequate cooling (check temp with `vcgencmd measure_temp`)

### Ollama not responding

**Issue**: "Ollama not available" error

**Solutions**:
```bash
# Check if Ollama is running
~/ai-helper.sh status

# Start Ollama if needed
~/ai-helper.sh start

# Verify model is downloaded
~/ai-helper.sh models
```

### No audio output

**Issue**: Text prints but doesn't speak

**Solutions**:
1. Check audio output: `speaker-test -t wav`
2. Install eSpeak: `sudo apt install espeak`
3. Test: `espeak "Hello world"`

### Weather not showing

**Issue**: Morning greeting doesn't include weather

**Solution**:
```bash
# Add your location to config
nano ~/.piai_assistant_config.json
# Change "location": "" to "location": "YourCity"
```

---

## 📊 Performance

On Raspberry Pi 5 (8GB) with phi3:mini:

| Component | Time | Notes |
|-----------|------|-------|
| Wake word detection | Real-time | ~10ms latency |
| Speech-to-text (5 sec audio) | 2-3 seconds | Using Whisper "base" |
| LLM response generation | 3-5 seconds | Depends on response length |
| Text-to-speech | 1-2 seconds | Using eSpeak |
| **Total interaction** | **6-10 seconds** | From speech to response |

**Tips for better performance:**
- Use phi3:mini (fastest quality model)
- Keep questions concise
- Use Whisper "tiny" model for speed
- Add active cooling for sustained use

---

## 🔬 Research & Inspiration

This project builds on work from prominent Pi makers:

- **Jeff Geerling** - Pi AI experimentation and benchmarking
- **NetworkChuck** - Making Pi projects accessible
- **Raspberry Pi Foundation** - AI HAT+ and official examples
- **Privacy-first community** - Projects like Home Assistant, PrivacyTools.io

**What we do differently:**
- **Zero cloud dependencies** (most tutorials use cloud APIs)
- **Production-ready code** (not just proof-of-concept)
- **Privacy by design** (not privacy as an afterthought)
- **Fully documented** (explain every choice)

---

## 🚀 Next Steps

Want to extend this assistant?

### Ideas for Enhancement

1. **Memory across sessions**
   - Store conversation history locally
   - Build context over time

2. **Smart home control**
   - Control lights, thermostat via GPIO
   - Integrate with Home Assistant

3. **Calendar integration**
   - Read events from local calendar file
   - Set reminders

4. **Music control**
   - "Play my favorite playlist"
   - Control MPD or local music player

5. **Custom skills**
   - Timer/alarm functionality
   - Unit conversions
   - Quick calculations

### Contributing

Have an improvement? Submit a PR to:
https://github.com/dougrichards13/PiAI

---

## 📜 License

This project is part of PiAI and licensed under the **MIT License**.

**You can:**
- ✅ Use commercially
- ✅ Modify however you want
- ✅ Distribute freely
- ✅ Use privately

**You must:**
- Include copyright notice
- Include license text

**No warranties or liability.**

See [LICENSE](../../LICENSE) for full details.

---

## 🙏 Credits

**Created by**: Doug Richards, Executive Chairman, Smart Factory  
**Project**: PiAI - Privacy-First AI for Raspberry Pi  
**Website**: https://smartfactory.io  
**Repository**: https://github.com/dougrichards13/PiAI

**Built with:**
- openWakeWord by David Scripka
- OpenAI Whisper
- Ollama by Ollama team
- Piper TTS by Rhasspy
- wttr.in weather service

**Special thanks** to the Raspberry Pi Foundation and the open-source community for making privacy-focused AI accessible to everyone.

---

## 💡 Philosophy

This assistant represents what we believe AI should be:

**Local** - Your hardware, your data, your control  
**Private** - No tracking, no cloud, no surveillance  
**Transparent** - Open source, auditable, modifiable  
**Accessible** - Works on affordable hardware ($100-200)  
**Practical** - Solves real problems, not gimmicks  
**Fun** - AI should empower and delight, not extract

**Your conversations belong to you.** Not to Big Tech.

---

*Made with ❤️ for the Pi community by Smart Factory | November 2025*
