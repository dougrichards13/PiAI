# Simple Chatbot Example

A minimal example showing how to build a chatbot using Ollama on your PiAI.

## What You'll Build

A command-line chatbot that:
- Remembers conversation context
- Responds intelligently to your questions
- Runs completely offline on your Pi

## Prerequisites

- Completed [JumpStart Guide](../../docs/JumpStart.md)
- Ollama installed and running
- At least one model downloaded (e.g., `phi3:mini`)

## Quick Start

```bash
# Make sure Ollama is running
../..ai-helper.sh status

# Download a model if you haven't already
../../ai-helper.sh pull phi3:mini

# Run the chatbot
python chatbot.py
```

## How It Works

The chatbot uses Ollama's REST API to:
1. Send your message to the AI model
2. Maintain conversation history for context
3. Display the AI's response

## Code Explanation

```python
import requests

# Ollama API endpoint (runs locally)
API_URL = "http://localhost:11434/api/generate"

# Send message to AI
response = requests.post(API_URL, json={
    "model": "phi3:mini",
    "prompt": "Your message here",
    "stream": False
})

# Get AI's response
ai_response = response.json()['response']
print(ai_response)
```

## Customization Ideas

1. **Change the model**: Replace `"phi3:mini"` with any installed model
2. **Add a system prompt**: Give your chatbot a personality
3. **Save conversations**: Log chats to a file
4. **Web interface**: Use Flask to create a web UI

## Next Steps

- Add voice input with [whisper.cpp](https://github.com/ggerganov/whisper.cpp)
     - Whisper is a port from OpenAI but, all audio processing occurs locally (CPU on the Pi). No data collection and no data is used for training however, use common sense in your ecosystem to protect your privacy and security to prevent any third party modifications of the port functionality.
- Create a web interface with the [web-chatbot example](../web-chatbot/)
- Fine-tune a model on your conversations with [fine-tuning example](../fine-tuning/)

## Troubleshooting

**Error: Connection refused**
- Make sure Ollama is running: `../../ai-helper.sh start`

**Model not found error**
- Download the model: `../../ai-helper.sh pull phi3:mini`

**Slow responses**
- Try a smaller model: `llama3.2:1b`
- Reduce context size in the code

---

*Part of the Smart Factory PiAI project*
