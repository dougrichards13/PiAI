#!/usr/bin/env python3
"""
PiAI Simple Voice Assistant - That Actually Works
Using proven libraries that work on Raspberry Pi 5

Libraries:
- Vosk: Offline speech recognition (Apache 2.0, proven on Pi)
- Ollama: Local LLM (already working)
- eSpeak: TTS (GPL, already installed)

No wake word complexity - just press Enter to talk.
100% local, no subscriptions, truly free.
"""

import os
import sys
import json
import subprocess
import pyaudio
import requests
from datetime import datetime
from pathlib import Path

try:
    from vosk import Model, KaldiRecognizer
except ImportError:
    print("Vosk not installed. Run:")
    print("  pip install vosk")
    print("  wget https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip")
    print("  unzip vosk-model-small-en-us-0.15.zip")
    sys.exit(1)


class SimpleAssistant:
    """A voice assistant that actually works on Pi 5"""
    
    def __init__(self):
        self.user_name = "Doug"
        self.assistant_name = "PiAI"
        
        # Load config
        self.config_file = Path.home() / ".piai_simple_config.json"
        self.load_config()
        
        print(f"\nInitializing {self.assistant_name} for {self.user_name}...")
        
        # Initialize components
        self.init_vosk()
        self.init_ollama()
        
        print(f"[OK] {self.assistant_name} ready!\n")
    
    def load_config(self):
        """Load user configuration"""
        if self.config_file.exists():
            with open(self.config_file) as f:
                config = json.load(f)
                self.user_name = config.get("user_name", "Doug")
                self.location = config.get("location", "")
        else:
            config = {
                "user_name": "Doug",
                "location": ""  # Add your city for weather
            }
            with open(self.config_file, 'w') as f:
                json.dump(config, f, indent=2)
            self.location = ""
    
    def init_vosk(self):
        """Initialize Vosk speech recognition"""
        model_path = Path("vosk-model-small-en-us-0.15")
        
        if not model_path.exists():
            print("[ERROR] Vosk model not found!")
            print("\nDownload it with:")
            print("  cd ~/PiAI/examples/personal-assistant")
            print("  wget https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip")
            print("  unzip vosk-model-small-en-us-0.15.zip")
            sys.exit(1)
        
        print("[VOSK] Loading speech model...")
        self.vosk_model = Model(str(model_path))
        self.recognizer = KaldiRecognizer(self.vosk_model, 16000)
        
        # Initialize audio
        self.audio = pyaudio.PyAudio()
        
        # Find USB microphone
        mic_index = None
        for i in range(self.audio.get_device_count()):
            info = self.audio.get_device_info_by_index(i)
            if 'USB' in info['name'] and info['maxInputChannels'] > 0:
                mic_index = i
                print(f"[MIC] Using: {info['name']}")
                break
        
        if mic_index is None:
            print("[WARN] USB mic not found, using default")
            mic_index = 0
        
        self.mic_index = mic_index
        print("[OK] Speech recognition ready")
    
    def init_ollama(self):
        """Check Ollama and model"""
        try:
            response = requests.get("http://localhost:11434/api/tags", timeout=2)
            models = response.json().get('models', [])
            
            if any('phi3' in m['name'] for m in models):
                self.model = "phi3:mini"
            elif models:
                self.model = models[0]['name']
            else:
                print("[ERROR] No Ollama models found")
                print("  Download: ~/ai-helper.sh pull phi3:mini")
                self.model = None
            
            if self.model:
                print(f"[LLM] Using: {self.model}")
        except Exception as e:
            print(f"[ERROR] Ollama not running: {e}")
            print("  Start: ~/ai-helper.sh start")
            self.model = None
    
    def listen(self):
        """Listen and transcribe speech with Vosk"""
        print("\n[LISTENING] Speak now... (5 seconds)")
        
        stream = self.audio.open(
            format=pyaudio.paInt16,
            channels=1,
            rate=16000,
            input=True,
            input_device_index=self.mic_index,
            frames_per_buffer=4000
        )
        
        stream.start_stream()
        
        # Record for 5 seconds
        frames_to_capture = int(16000 / 4000 * 5)  # 5 seconds
        
        for _ in range(frames_to_capture):
            data = stream.read(4000, exception_on_overflow=False)
            
            if self.recognizer.AcceptWaveform(data):
                result = json.loads(self.recognizer.Result())
                text = result.get('text', '')
                if text:
                    stream.stop_stream()
                    stream.close()
                    return text
        
        # Get final result
        result = json.loads(self.recognizer.FinalResult())
        text = result.get('text', '')
        
        stream.stop_stream()
        stream.close()
        
        # Reset recognizer for next use
        self.recognizer = KaldiRecognizer(self.vosk_model, 16000)
        
        return text if text else None
    
    def get_weather(self):
        """Get weather if location is set"""
        if not self.location:
            return ""
        
        try:
            response = requests.get(
                f"https://wttr.in/{self.location}?format=j1",
                timeout=3
            )
            data = response.json()
            current = data['current_condition'][0]
            temp_f = current['temp_F']
            desc = current['weatherDesc'][0]['value']
            return f"The weather in {self.location} is {temp_f}°F and {desc.lower()}. "
        except:
            return ""
    
    def get_response(self, user_input):
        """Get AI response from Ollama"""
        if not self.model:
            return "I need an AI model to respond. Please download phi3:mini."
        
        # Check for greeting
        is_greeting = any(word in user_input.lower() 
                         for word in ["hello", "hi", "hey", "good morning"])
        
        # Build prompt
        hour = datetime.now().hour
        time_of_day = "morning" if hour < 12 else "afternoon" if hour < 18 else "evening"
        
        system_prompt = f"""You are {self.assistant_name}, a helpful AI assistant for {self.user_name} Richards.
You run on a Raspberry Pi 5 - completely private and local.
Be friendly, concise, and helpful. Current time: {datetime.now().strftime('%I:%M %p')}"""

        # Add weather for greetings
        if is_greeting:
            weather = self.get_weather()
            if weather:
                system_prompt += f"\n{weather}"
        
        try:
            response = requests.post(
                "http://localhost:11434/api/generate",
                json={
                    "model": self.model,
                    "prompt": f"System: {system_prompt}\n\nUser: {user_input}\n\nAssistant:",
                    "stream": False,
                    "options": {
                        "temperature": 0.7,
                        "num_predict": 100
                    }
                },
                timeout=30
            )
            
            result = response.json()
            return result.get('response', '').strip()
        except Exception as e:
            return f"Sorry, error: {e}"
    
    def speak(self, text):
        """Speak with eSpeak"""
        print(f"\n[{self.assistant_name}]: {text}\n")
        
        try:
            # Use espeak - already installed
            subprocess.run(
                ["espeak", "-s", "150", text],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
        except:
            pass  # Silent mode if espeak fails
    
    def run(self):
        """Main loop"""
        print("="*50)
        print(f"  {self.assistant_name} Voice Assistant")
        print("="*50)
        print("\nPress Enter to talk, Ctrl+C to exit\n")
        
        try:
            while True:
                input("Press Enter to start recording... ")
                
                # Listen
                text = self.listen()
                
                if text:
                    print(f"[YOU]: {text}")
                    
                    # Get response
                    response = self.get_response(text)
                    
                    # Speak
                    self.speak(response)
                else:
                    print("[INFO] Didn't hear anything. Try again.\n")
        
        except KeyboardInterrupt:
            print(f"\nGoodbye, {self.user_name}!")
        finally:
            self.audio.terminate()


def main():
    assistant = SimpleAssistant()
    assistant.run()


if __name__ == "__main__":
    main()
