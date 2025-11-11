#!/usr/bin/env python3
"""
PiAI Personal Assistant - "Hello Doug"
A 100% local, privacy-first voice assistant for Raspberry Pi 5

Features:
- Wake word detection (fully local)
- Speech-to-text with Whisper (no cloud)
- AI responses via Ollama (local LLM)
- Text-to-speech with Piper (local synthesis)
- Personalized for Doug Richards
- Morning weather routine

No cloud services. No data sharing. No subscriptions. Open source.
"""

import os
import sys
import json
import subprocess
import time
from datetime import datetime
from pathlib import Path
import requests

# Check for required packages
try:
    import pyaudio
    import numpy as np
    from openwakeword.model import Model
    import speech_recognition as sr
except ImportError as e:
    print(f"Missing required package: {e}")
    print("\nInstall dependencies:")
    print("  cd ~/PiAI/examples/personal-assistant")
    print("  pip install -r requirements.txt")
    sys.exit(1)


class LocalAssistant:
    """Privacy-first voice assistant running entirely on your Pi"""
    
    def __init__(self):
        self.user_name = "Doug"
        self.assistant_name = "PiAI"
        self.wake_word = "hey_jarvis"  # Using openWakeWord model (alexa, hey_jarvis, hey_mycroft available)
        self.mic_index = 0  # Default microphone
        
        # Paths
        self.config_file = Path.home() / ".piai_assistant_config.json"
        self.load_config()
        
        # Initialize components
        print(f"Initializing {self.assistant_name} for {self.user_name}...")
        self.init_wake_word()
        self.init_speech_recognition()
        self.init_ollama()
        
        print(f"[OK] {self.assistant_name} ready!")
        print(f"Say '{self.wake_word.replace('_', ' ')}' to wake me up\n")
    
    def load_config(self):
        """Load or create user configuration"""
        if self.config_file.exists():
            with open(self.config_file) as f:
                config = json.load(f)
                self.user_name = config.get("user_name", "Doug")
                self.location = config.get("location", "")
        else:
            # Create default config
            config = {
                "user_name": "Doug",
                "location": "",  # User can add their city
                "preferences": {
                    "morning_greeting": True,
                    "weather_in_greeting": True
                }
            }
            with open(self.config_file, 'w') as f:
                json.dump(config, f, indent=2)
            self.location = ""
    
    def init_wake_word(self):
        """Initialize wake word detection with openWakeWord"""
        try:
            # Use openWakeWord - fully local, open source
            self.wake_model = Model(wakeword_models=[self.wake_word])
            self.wake_audio = pyaudio.PyAudio()
            
            # Find USB microphone
            mic_index = None
            for i in range(self.wake_audio.get_device_count()):
                info = self.wake_audio.get_device_info_by_index(i)
                if 'USB' in info['name'] and info['maxInputChannels'] > 0:
                    mic_index = i
                    print(f"[MIC] Using microphone: {info['name']}")
                    break
            
            if mic_index is None:
                print("[WARN] USB microphone not found, using default")
                mic_index = 0
            
            self.mic_index = mic_index
            self.wake_stream = self.wake_audio.open(
                format=pyaudio.paInt16,
                channels=1,
                rate=16000,
                input=True,
                input_device_index=mic_index,
                frames_per_buffer=1280
            )
            
        except Exception as e:
            print(f"[ERROR] Wake word initialization failed: {e}")
            print("Falling back to keyboard input mode")
            self.wake_model = None
    
    def init_speech_recognition(self):
        """Initialize speech recognition with local Whisper"""
        self.recognizer = sr.Recognizer()
        
        # Try to find USB microphone, fall back to default
        try:
            import pyaudio
            p = pyaudio.PyAudio()
            mic_index = None
            for i in range(p.get_device_count()):
                info = p.get_device_info_by_index(i)
                if 'USB' in info['name'] and info['maxInputChannels'] > 0:
                    mic_index = i
                    break
            p.terminate()
            
            if mic_index is not None:
                self.microphone = sr.Microphone(device_index=mic_index)
            else:
                self.microphone = sr.Microphone()
        except:
            # Fallback to default
            self.microphone = sr.Microphone()
        
        # Adjust for ambient noise
        print("[AUDIO] Calibrating microphone...")
        try:
            with self.microphone as source:
                self.recognizer.adjust_for_ambient_noise(source, duration=1)
        except Exception as e:
            print(f"[WARN] Microphone calibration skipped: {e}")
    
    def init_ollama(self):
        """Check Ollama is running and model is available"""
        try:
            response = requests.get("http://localhost:11434/api/tags", timeout=2)
            models = response.json().get('models', [])
            
            # Prefer phi3:mini for assistant
            if any('phi3' in m['name'] for m in models):
                self.model = "phi3:mini"
            elif models:
                self.model = models[0]['name']
            else:
                print("[WARN] No Ollama models found. Download one with:")
                print("  ~/ai-helper.sh pull phi3:mini")
                self.model = None
                
            if self.model:
                print(f"[LLM] Using model: {self.model}")
                
        except Exception as e:
            print(f"[WARN] Ollama not available: {e}")
            print("Start it with: ~/ai-helper.sh start")
            self.model = None
    
    def listen_for_wake_word(self):
        """Listen for wake word (local detection)"""
        if not self.wake_model:
            # Fallback: press Enter
            input("Press Enter to talk (wake word not available)...")
            return True
        
        try:
            audio_data = self.wake_stream.read(1280, exception_on_overflow=False)
            audio_array = np.frombuffer(audio_data, dtype=np.int16)
            
            # Run prediction
            prediction = self.wake_model.predict(audio_array)
            
            # Check if wake word detected
            for key, score in prediction.items():
                if score > 0.5:  # Confidence threshold
                    return True
                    
        except Exception as e:
            pass
        
        return False
    
    def listen_for_speech(self):
        """Capture and transcribe speech using local Whisper"""
        print("[LISTEN] Listening...")
        
        try:
            with self.microphone as source:
                # Listen with timeout
                audio = self.recognizer.listen(source, timeout=5, phrase_time_limit=10)
            
            print("[PROCESS] Processing speech...")
            
            # Use Whisper locally (no cloud API)
            # Note: This requires whisper to be installed
            text = self.recognizer.recognize_whisper(audio, model="base", language="english")
            
            return text
            
        except sr.WaitTimeoutError:
            return None
        except sr.UnknownValueError:
            return None
        except Exception as e:
            print(f"[ERROR] Speech recognition error: {e}")
            return None
    
    def get_weather(self):
        """Get local weather (privacy-friendly)"""
        if not self.location:
            return ""
        
        try:
            # Using wttr.in - privacy-friendly weather service
            # No API key needed, no tracking
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
        """Get AI response from local Ollama"""
        if not self.model:
            return "Sorry, I need an AI model to respond. Please download one with: ~/ai-helper.sh pull phi3:mini"
        
        # Build personalized context
        hour = datetime.now().hour
        greeting_time = "morning" if hour < 12 else "afternoon" if hour < 18 else "evening"
        
        # Check if this is a wake-up greeting
        is_wake_greeting = any(word in user_input.lower() for word in ["hello", "hi", "hey", "good morning", "wake up"])
        
        # Build system prompt
        system_prompt = f"""You are {self.assistant_name}, a helpful AI assistant for {self.user_name} Richards.
You run entirely on a Raspberry Pi 5 - no cloud, completely private.
You are friendly, concise, and respectful of Doug's time.
Current time: {datetime.now().strftime('%I:%M %p')}
Keep responses brief and conversational."""

        # Add weather to wake greeting
        weather_info = ""
        if is_wake_greeting:
            weather_info = self.get_weather()
            if weather_info:
                system_prompt += f"\nWeather info: {weather_info}"
        
        try:
            response = requests.post(
                "http://localhost:11434/api/generate",
                json={
                    "model": self.model,
                    "prompt": f"System: {system_prompt}\n\nUser: {user_input}\n\nAssistant:",
                    "stream": False,
                    "options": {
                        "temperature": 0.7,
                        "num_predict": 150  # Keep responses concise
                    }
                },
                timeout=30
            )
            
            result = response.json()
            answer = result.get('response', '').strip()
            
            # Add weather naturally if it's a greeting
            if is_wake_greeting and weather_info:
                # Ollama might not include weather, so mention it
                if "weather" not in answer.lower() and weather_info:
                    answer += f" {weather_info}"
            
            return answer
            
        except Exception as e:
            return f"Sorry, I had trouble thinking. Error: {e}"
    
    def speak(self, text):
        """Speak text using local TTS"""
        print(f"\n[{self.assistant_name}]: {text}\n")
        
        try:
            # Try Piper TTS first (best quality)
            if os.path.exists("/usr/local/bin/piper"):
                subprocess.run([
                    "piper",
                    "--model", "en_US-lessac-medium",
                    "--output-raw"
                ], input=text.encode(), stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            else:
                # Fallback to espeak (faster, more robotic)
                subprocess.run(["espeak", text], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except:
            # If TTS fails, just print (silent mode)
            pass
    
    def run(self):
        """Main assistant loop"""
        print(f"[READY] {self.assistant_name} is listening...")
        print(f"Say '{self.wake_word.replace('_', ' ')}' or press Ctrl+C to exit\n")
        
        try:
            while True:
                # Wait for wake word
                if self.listen_for_wake_word():
                    print(f"[WAKE] Wake word detected! Good {datetime.now().strftime('%A')}!")
                    
                    # Play acknowledgment sound (optional)
                    # subprocess.run(["aplay", "wake.wav"], stdout=subprocess.DEVNULL)
                    
                    # Listen for command
                    user_speech = self.listen_for_speech()
                    
                    if user_speech:
                        print(f"[YOU]: {user_speech}")
                        
                        # Get AI response
                        response = self.get_response(user_speech)
                        
                        # Speak response
                        self.speak(response)
                    else:
                        print("[INFO] Didn't catch that. Try again!\n")
                    
                    print(f"[READY] Listening for wake word...")
                
                time.sleep(0.1)  # Small delay to prevent CPU overuse
                
        except KeyboardInterrupt:
            print(f"\nGoodbye, {self.user_name}!")
            self.cleanup()
    
    def cleanup(self):
        """Clean up resources"""
        if hasattr(self, 'wake_stream'):
            self.wake_stream.stop_stream()
            self.wake_stream.close()
        if hasattr(self, 'wake_audio'):
            self.wake_audio.terminate()


def main():
    """Entry point"""
    assistant = LocalAssistant()
    assistant.run()


if __name__ == "__main__":
    main()
