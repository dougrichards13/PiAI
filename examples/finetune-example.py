#!/usr/bin/env python3
"""
Example Fine-tuning Script for Raspberry Pi 5
Uses LoRA (Low-Rank Adaptation) for memory-efficient fine-tuning

PRIVACY: This script operates entirely offline. Make sure to:
1. Pre-download models before enabling offline mode
2. Prepare datasets locally
3. Keep HF_HUB_OFFLINE=1 during training

Usage:
    source ~/ai-tools/venv/bin/activate
    python finetune-example.py
"""

import os
import torch
from transformers import (
    AutoModelForCausalLM,
    AutoTokenizer,
    TrainingArguments,
    Trainer,
    DataCollatorForLanguageModeling
)
from peft import LoraConfig, get_peft_model, TaskType
from datasets import Dataset

# Ensure offline mode (privacy)
os.environ["HF_HUB_OFFLINE"] = "1"
os.environ["TRANSFORMERS_OFFLINE"] = "1"

def create_sample_dataset():
    """
    Create a simple sample dataset for demonstration.
    Replace this with your own data loading logic.
    """
    data = {
        "text": [
            "The Raspberry Pi 5 is a powerful single-board computer.",
            "AI models can run locally for privacy and security.",
            "Fine-tuning allows models to specialize on specific tasks.",
            "LoRA is an efficient method for adapting large language models.",
            "Local AI ensures your data never leaves your device."
        ] * 10  # Repeat for more training samples
    }
    return Dataset.from_dict(data)

def tokenize_function(examples, tokenizer, max_length=128):
    """Tokenize the text data."""
    return tokenizer(
        examples["text"],
        truncation=True,
        padding="max_length",
        max_length=max_length,
        return_tensors="pt"
    )

def main():
    print("=" * 60)
    print("Fine-tuning Example for Raspberry Pi 5")
    print("Privacy: 100% Local, No External Data Transfer")
    print("=" * 60)
    
    # Configuration
    MODEL_NAME = "microsoft/phi-2"  # Change to your local model
    OUTPUT_DIR = "./finetuned-model"
    MAX_LENGTH = 128
    BATCH_SIZE = 1  # Small batch for Pi 5's memory
    EPOCHS = 3
    
    # Check if model exists locally
    model_path = os.path.expanduser(f"~/.cache/huggingface/hub/models--{MODEL_NAME.replace('/', '--')}")
    if not os.path.exists(model_path):
        print(f"\n⚠️  Model not found locally: {MODEL_NAME}")
        print("To download before going offline:")
        print(f"  1. Set HF_HUB_OFFLINE=0")
        print(f"  2. Run: python -c \"from transformers import AutoModel; AutoModel.from_pretrained('{MODEL_NAME}')\"")
        print(f"  3. Set HF_HUB_OFFLINE=1")
        return
    
    print(f"\n✅ Loading model: {MODEL_NAME}")
    
    # Load tokenizer and model
    tokenizer = AutoTokenizer.from_pretrained(
        MODEL_NAME,
        local_files_only=True,
        trust_remote_code=True
    )
    
    # Set padding token if not present
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token
    
    model = AutoModelForCausalLM.from_pretrained(
        MODEL_NAME,
        local_files_only=True,
        trust_remote_code=True,
        torch_dtype=torch.float32,  # Use float32 for CPU
        low_cpu_mem_usage=True
    )
    
    print(f"Model loaded. Parameters: {model.num_parameters():,}")
    
    # Configure LoRA
    print("\n✅ Configuring LoRA for efficient fine-tuning")
    lora_config = LoraConfig(
        r=8,  # Low rank for memory efficiency
        lora_alpha=16,
        target_modules=["q_proj", "v_proj"],  # Adjust based on model architecture
        lora_dropout=0.05,
        bias="none",
        task_type=TaskType.CAUSAL_LM
    )
    
    model = get_peft_model(model, lora_config)
    trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
    total_params = sum(p.numel() for p in model.parameters())
    
    print(f"Trainable parameters: {trainable_params:,} ({100 * trainable_params / total_params:.2f}%)")
    
    # Prepare dataset
    print("\n✅ Preparing dataset")
    dataset = create_sample_dataset()
    tokenized_dataset = dataset.map(
        lambda x: tokenize_function(x, tokenizer, MAX_LENGTH),
        batched=True,
        remove_columns=dataset.column_names
    )
    
    print(f"Dataset size: {len(tokenized_dataset)} examples")
    
    # Training arguments
    training_args = TrainingArguments(
        output_dir=OUTPUT_DIR,
        num_train_epochs=EPOCHS,
        per_device_train_batch_size=BATCH_SIZE,
        gradient_accumulation_steps=4,  # Simulate larger batch
        learning_rate=2e-4,
        logging_steps=10,
        save_strategy="epoch",
        fp16=False,  # Pi 5 CPU doesn't support fp16
        dataloader_num_workers=0,  # Single worker for stability
        report_to="none",  # No external reporting (privacy)
    )
    
    # Data collator
    data_collator = DataCollatorForLanguageModeling(
        tokenizer=tokenizer,
        mlm=False
    )
    
    # Trainer
    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=tokenized_dataset,
        data_collator=data_collator,
    )
    
    # Train
    print("\n✅ Starting training...")
    print("⚠️  This may take a while on Pi 5. Monitor with: htop")
    
    try:
        trainer.train()
        print("\n✅ Training completed!")
        
        # Save the fine-tuned model
        print(f"\n✅ Saving model to {OUTPUT_DIR}")
        model.save_pretrained(OUTPUT_DIR)
        tokenizer.save_pretrained(OUTPUT_DIR)
        
        print("\n" + "=" * 60)
        print("Fine-tuning Complete!")
        print(f"Model saved to: {OUTPUT_DIR}")
        print("To use the model:")
        print(f"  from transformers import AutoModelForCausalLM")
        print(f"  model = AutoModelForCausalLM.from_pretrained('{OUTPUT_DIR}')")
        print("=" * 60)
        
    except KeyboardInterrupt:
        print("\n⚠️  Training interrupted by user")
        print("Partial results may be saved in:", OUTPUT_DIR)
    except Exception as e:
        print(f"\n❌ Error during training: {e}")
        raise

if __name__ == "__main__":
    main()
