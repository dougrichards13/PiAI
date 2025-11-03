#!/usr/bin/env python3
"""
Simple Chatbot Example for PiAI
A minimal chatbot using Ollama's API with conversation context.
"""

import requests
import json
from datetime import datetime

# Configuration
API_URL = "http://localhost:11434/api/generate"
MODEL = "phi3:mini"  # Change to any installed model

# Colors for terminal output
class Colors:
    USER = '\033[94m'      # Blue
    AI = '\033[92m'        # Green
    SYSTEM = '\033[93m'    # Yellow
    ERROR = '\033[91m'     # Red
    RESET = '\033[0m'      # Reset

def print_colored(text, color):
    """Print colored text to terminal."""
    print(f"{color}{text}{Colors.RESET}")

def check_ollama_connection():
    """Verify Ollama server is running."""
    try:
        response = requests.get("http://localhost:11434/api/tags", timeout=2)
        return response.status_code == 200
    except requests.exceptions.RequestException:
        return False

def get_ai_response(prompt, conversation_history=""):
    """Send prompt to Ollama and get response."""
    # Build context from conversation history
    full_prompt = conversation_history + "\nUser: " + prompt + "\nAssistant:"
    
    try:
        response = requests.post(
            API_URL,
            json={
                "model": MODEL,
                "prompt": full_prompt,
                "stream": False,
                "options": {
                    "temperature": 0.7,
                    "top_p": 0.9,
                }
            },
            timeout=60
        )
        
        if response.status_code == 200:
            return response.json()['response']
        else:
            return f"Error: Server returned status {response.status_code}"
            
    except requests.exceptions.Timeout:
        return "Error: Request timed out. Try a smaller model or shorter prompt."
    except requests.exceptions.RequestException as e:
        return f"Error: {str(e)}"

def save_conversation(conversation_history):
    """Save conversation to a log file."""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"conversation_{timestamp}.txt"
    
    with open(filename, 'w') as f:
        f.write(conversation_history)
    
    return filename

def main():
    """Main chatbot loop."""
    print_colored("\n" + "=" * 60, Colors.SYSTEM)
    print_colored("         Smart Factory PiAI - Simple Chatbot", Colors.SYSTEM)
    print_colored("=" * 60 + "\n", Colors.SYSTEM)
    
    # Check Ollama connection
    print_colored("Checking Ollama connection...", Colors.SYSTEM)
    if not check_ollama_connection():
        print_colored("❌ Error: Cannot connect to Ollama server", Colors.ERROR)
        print_colored("   Please start Ollama: ./ai-helper.sh start\n", Colors.SYSTEM)
        return
    
    print_colored(f"✅ Connected to Ollama (model: {MODEL})\n", Colors.SYSTEM)
    print_colored("Commands:", Colors.SYSTEM)
    print_colored("  /bye  - Exit chatbot", Colors.SYSTEM)
    print_colored("  /save - Save conversation to file", Colors.SYSTEM)
    print_colored("  /new  - Start new conversation\n", Colors.SYSTEM)
    
    conversation_history = ""
    
    while True:
        # Get user input
        try:
            user_input = input(f"{Colors.USER}You: {Colors.RESET}").strip()
        except (KeyboardInterrupt, EOFError):
            print()  # New line
            break
        
        # Handle special commands
        if user_input.lower() == '/bye':
            print_colored("\nGoodbye! 👋\n", Colors.SYSTEM)
            break
        
        elif user_input.lower() == '/save':
            if conversation_history:
                filename = save_conversation(conversation_history)
                print_colored(f"\n✅ Conversation saved to: {filename}\n", Colors.SYSTEM)
            else:
                print_colored("\n⚠️  No conversation to save yet.\n", Colors.SYSTEM)
            continue
        
        elif user_input.lower() == '/new':
            conversation_history = ""
            print_colored("\n✅ Started new conversation.\n", Colors.SYSTEM)
            continue
        
        # Skip empty input
        if not user_input:
            continue
        
        # Get AI response
        print_colored("AI: ", Colors.AI, end='')
        print_colored("(thinking...)", Colors.SYSTEM, end='\r')
        
        ai_response = get_ai_response(user_input, conversation_history)
        
        # Clear "thinking" message and print response
        print(' ' * 30, end='\r')  # Clear line
        print_colored(f"{ai_response}\n", Colors.AI)
        
        # Update conversation history
        conversation_history += f"\nUser: {user_input}\nAssistant: {ai_response}"

if __name__ == "__main__":
    main()
