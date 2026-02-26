# Open Yapper — Local Backend (Ollama)

A minimal Sinatra server that bridges the Flutter app to a local Ollama instance for fully offline, privacy-first voice processing.

## Prerequisites

- Ruby 3.x
- [Ollama](https://ollama.com) installed and running

## Setup

### 1. Pull required Ollama models

```bash
# Whisper for transcription
ollama pull whisper

# LLM for text processing (or any model you prefer)
ollama pull llama3.2
```

### 2. Install Ruby dependencies

```bash
cd backend
bundle install
```

### 3. Start the server

```bash
ruby server.rb
```

The server starts on `http://127.0.0.1:11435`.

### 4. Verify it is running

```bash
curl http://localhost:11435/health
# {"status":"ok"}
```

## Configuration

| Environment variable | Default                  | Description                     |
|----------------------|--------------------------|---------------------------------|
| `OLLAMA_BASE`        | `http://localhost:11434` | Base URL of the Ollama instance |

Example with a custom Ollama URL:

```bash
OLLAMA_BASE=http://my-server:11434 ruby server.rb
```

## API

### `GET /health`
Returns `{"status":"ok"}` when the server is up.

### `POST /process_audio`
Multipart form data:
- `audio` — M4A audio file
- `system_prompt` — system prompt string
- `model` *(optional)* — Ollama model name, default `llama3.2`

Returns `{"text":"..."}`.

### `POST /process_text`
JSON body:
- `transcription` — already-transcribed text
- `system_prompt` — system prompt string
- `model` *(optional)* — Ollama model name, default `llama3.2`

Returns `{"text":"..."}`.

## Flutter app settings

In the Open Yapper app, go to **Settings → LLM Provider** and select **Local (Ollama)**. Configure the backend URL (default `http://localhost:11435`) and the model name.
