# PiAI Example Projects

Welcome to the PiAI examples! These projects demonstrate what you can build with your Raspberry Pi 5 AI setup.

## Available Examples

### 1. Simple Chatbot
**Directory:** `simple-chatbot/`  
**Difficulty:** Beginner  
**Description:** A terminal-based chatbot with conversation context and command support.

**Features:**
- Conversation history
- Save conversations to file
- Colored output
- Multiple commands (/bye, /save, /new)

**Quick Start:**
```bash
cd simple-chatbot
python chatbot.py
```

[📖 Full Documentation](simple-chatbot/README.md)

---

### 2. Fine-Tuning Example
**File:** `finetune-example.py`  
**Difficulty:** Advanced  
**Description:** Learn how to fine-tune AI models using LoRA for custom applications.

**Features:**
- Memory-efficient LoRA training
- Offline operation
- Sample dataset included
- Detailed comments

**Quick Start:**
```bash
source ~/ai-tools/venv/bin/activate
python finetune-example.py
```

---

## Coming Soon

### Personal AI Assistant (Repository Link TBD)
Voice-controlled assistant with:
- Speech recognition (Whisper)
- Text-to-speech
- Smart home integration
- Fully offline

### Smart Camera with Object Detection (Repository Link TBD)
AI-powered security camera:
- Real-time object detection
- Hailo AI HAT acceleration
- Recording and alerts
- Web interface

### Document Q&A Chatbot (Repository Link TBD)
Chat with your documents:
- RAG (Retrieval Augmented Generation)
- PDF/text file support
- Citation tracking
- Privacy-focused

### Raspberry Pi Cluster AI (Repository Link TBD)
Distributed inference:
- Multiple Pi 5s working together
- Load balancing
- Faster inference
- Scalable architecture

---

## Creating Your Own Example

Want to contribute an example project? Great! Here's how:

### Structure
```
examples/your-project/
├── README.md           # Project documentation
├── main.py            # Main script
├── requirements.txt   # Additional dependencies (if any)
└── assets/           # Images, sample data, etc.
```

### README Template
Your README should include:
1. **Description** - What does it do?
2. **Prerequisites** - What's needed?
3. **Installation** - How to set up?
4. **Usage** - How to run?
5. **Customization** - How to modify?
6. **Troubleshooting** - Common issues
7. **Credits** - Acknowledge sources

### Submission
1. Create your example
2. Test thoroughly on Raspberry Pi 5
3. Submit a pull request
4. See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines

---

## Example Ideas

Need inspiration? Here are some project ideas:

**Beginner:**
- Weather forecast chatbot
- Recipe recommender
- Mood tracker with AI journaling
- Local code assistant

**Intermediate:**
- Smart garden monitor with AI insights
- Pet activity detector
- AI-powered alarm clock
- Voice-controlled music player

**Advanced:**
- Real-time translation device
- AI fitness coach
- Autonomous robot controller
- Edge AI for industrial monitoring

---

## Resources

### Learning Materials
- [Smart Factory PiAI Guide](../docs/Smart_Factory_PiAI.md)
- [Ollama Documentation](https://ollama.com/docs)
- [llama.cpp Repository](https://github.com/ggerganov/llama.cpp)
- [Hugging Face Tutorials](https://huggingface.co/docs)

### Community
- [GitHub Discussions](https://github.com/dougrichards13/PiAI/discussions)
- [Smart Factory Community](https://smartfactory.io/community)
- [Project Showcase](https://smartfactory.io/showcase)

---

## Getting Help

**Having issues with an example?**
1. Check the example's README troubleshooting section
2. Search [GitHub Issues](https://github.com/dougrichards13/PiAI/issues)
3. Ask in [GitHub Discussions](https://github.com/dougrichards13/PiAI/discussions)
4. Join [Smart Factory Community](https://smartfactory.io/community)

---

## Share Your Creations

Built something awesome? Share it!
- Submit to [Smart Factory Showcase](https://smartfactory.io/showcase)
- Tag **@SmartFactoryIO** on social media
- Contribute back to this repository

---

*Part of the Smart Factory PiAI project - Making AI accessible, private, and practical for everyone.*
