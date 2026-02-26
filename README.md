![Open Yapper Screenshot](assets/Screenshot%202026-02-22%20at%2017.34.42.png)

# [Open Yapper](https://www.openyapper.com) (OY!) — Cursor Hackathon 2026 Vancouver Winner

**Done in 4 hours @ Cursor Hackathon** — Full app + Landing page  
**Winner** — Cursor Hackathon 2026 (Vancouver)

---

## What is Open Yapper?

**Open Yapper** (OY!) is the GEN Z voice dictation app. It's an open-source clone of [Wispr Flow](https://wisprflow.ai/)—ramble naturally, AI cleans the mess, no cap.

Stop typing, start talking. Speak into your mic, and Open Yapper transcribes your voice, removes filler words (um, uh, like, you know), and turns your rambled thoughts into polished text ready to paste anywhere—Gmail, Slack, Notes, ChatGPT, you name it.

### Key Features

- **Voice-to-text transcription** — Record your voice and get clean, formatted text
- **Filler word removal** — Automatically strips "um," "uh," "like," and other verbal hiccups
- **Gen Z mode** — Optional rewrite into Gen Z slang (lowkey, no cap, slay, it's giving, etc.)
- **Dictionary memory** — Manage Corrections, Frequent Terms, and Suggestions with enable/disable controls
- **User info aliases** — Save personal fields (email, phone, links, etc.) so phrases like "my email" auto-expand
- **Phrase expansion pipeline** — Expands user aliases + dictionary replacements before pasting
- **LLM provider choice** — Switch between Gemini (cloud) and Local (Ollama) in Settings with no restart needed
- **Local/offline mode** — Run entirely on-device with Ollama + whisper.cpp via the included Ruby backend; no API key required
- **Model selection** — Choose between Gemini Flash Lite Latest (default) and Gemini Flash Latest (Gemini mode), or any Ollama model (local mode)
- **Per-app customization** — Configure tone + advanced custom prompt per app (Default + app-specific overrides)
- **Global hotkeys** — Configure start, stop, and hold-to-record hotkeys (all independently editable)
- **History & stats** — Browse past recordings, copy text, and see usage stats
- **Built-in update checks** — Launch + manual update checks with release notes preview
- **Paste anywhere** — Uses accessibility APIs to paste directly into the focused app

### Tech Stack

- **Flutter** — Cross-platform (macOS, iOS, Android, Web, Windows)
- **Google Gemini** — AI transcription and text refinement (cloud mode)
- **Ollama** — Local LLM inference (offline mode)
- **whisper.cpp** — On-device speech-to-text transcription (offline mode)
- **Ruby / Sinatra** — Lightweight local backend bridging the app to Ollama + whisper.cpp
- **Native macOS integration** — Hotkeys, accessibility, microphone permissions

---

## Download

**Website:** [www.openyapper.com](https://www.openyapper.com)

The website now includes the official **Download Open Yapper** button and is the recommended place to get the app.

It points to the latest stable macOS DMG from GitHub Releases (`open_yapper.dmg`), so users should download from the website first.

---

## Non-Technical Setup (Recommended)

If you want Open Yapper installed like a normal app (no IDE required), follow this:

### macOS quick install

1. Go to [www.openyapper.com](https://www.openyapper.com)
2. Click **Download Open Yapper**
3. Open the DMG
4. Drag `Open Yapper.app` into your **Applications** folder
5. Launch **Open Yapper** from Applications

This is the easiest path for non-technical users and always gives the latest public build.

### First launch checklist

- Allow **Microphone** permission
- Allow **Accessibility** permission (for pasting into other apps)
- Paste your Gemini API key in onboarding (or later in Settings)

---

## Technical Setup (Optional: Build from Source)

Use this only if you want to build your own local macOS app bundle from source code.

This repository is configured so local macOS release builds do not require your own Apple Developer signing certificate.

1. Clone this repository:

```bash
git clone <repo-url>
cd open_yapper
```

2. Install Flutter automatically (recommended):

```bash
bash scripts/setup_flutter_macos.sh
```

If you prefer manual installation, use the official guide: [Flutter install guide](https://docs.flutter.dev/get-started/install/macos)

3. Run:

```bash
flutter pub get
flutter build macos --release
```

4. When build finishes, open this folder:

```bash
build/macos/Build/Products/Release/
```

5. Drag `Open Yapper.app` into **Applications**
6. Launch from Applications from now on (no IDE needed)

### How to update later

When you want a newer version from source:

```bash
git pull
flutter pub get
flutter build macos --release
```

Then replace the old app in Applications with the new `Open Yapper.app`.

---

## How to Run (Development)

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.10+)
- [Dart](https://dart.dev/) 3.10+
- **Gemini mode:** A [Google Gemini API key](https://aistudio.google.com/apikey) (free tier available)
- **Local mode:** [Ollama](https://ollama.com), Ruby 3.x, and whisper.cpp (see [Local Mode Setup](#local-mode-setup-ollama--whispercpp) below)

### 1. Clone the repo

```bash
git clone https://github.com/your-org/open_yapper.git
cd open_yapper
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Add your Gemini API key

The app requires a Gemini API key for transcription. On first launch, you'll see an onboarding screen where you can paste your key. It's stored securely in the system keychain (macOS) or equivalent.

You can also set it via the Settings screen after onboarding.

### 4. Run the app

**macOS (primary platform):**

```bash
flutter run -d macos
```

**Other platforms:**

```bash
# iOS (requires Xcode and a Mac)
flutter run -d ios

# Android
flutter run -d android

# Web
flutter run -d chrome

# Windows
flutter run -d windows
```

### 5. Grant permissions

On first run, the app will ask for:

- **Microphone** — To record your voice
- **Accessibility** — To paste text into other apps (macOS)

Grant both in System Settings when prompted.

### 6. Start recording

- Press **⌥ Space** (Option+Space) to toggle recording
- Or hold the hotkey to record while pressed
- Speak naturally—the AI will clean up filler words and format the output
- The text is pasted into the currently focused app when done

### Voice formatting commands

Open Yapper can treat spoken formatting requests as instructions and shape output automatically.

- **Email formatting (explicit):**  
  Say: `Format this as an email ...`  
  Result: email output with `Subject:` line + body, without the control phrase text.
- **To-do or list formatting (explicit):**  
  Say: `Add this to my to-do list ...` or `Make this a list ...`  
  Result: one bullet per task item.
- **Implicit format inference:**  
  If you do not say an explicit command, Open Yapper infers format from context (e.g., greeting/sign-off for email, sequential cues for numbered steps).
- **Fallback behavior:**  
  If intent is unclear, output falls back to clean paragraph text.

---

## New Feature Guide

### Dictionary

- Open the **Dictionary** tab from the left sidebar
- Manage three buckets: **Corrections**, **Frequent Terms**, and **Suggestions**
- Add/edit manual entries, enable/disable entries, accept suggestions, and delete entries
- Frequent terms are learned automatically from past processed text

### User Info

- Open **User Info** to save profile fields (name, email, phone, LinkedIn, GitHub, website, Twitter/X, Instagram)
- Add custom aliases like `my portfolio` -> your actual link
- Use **Alias preview** to see exactly what phrases will expand

### Text Expansion

- In **Settings > Text Expansion**, turn **Phrase Expansion** on/off
- When enabled, Open Yapper expands:
  - User Info aliases (like "my email")
  - Enabled dictionary replacements/corrections
- Expansion runs automatically after Gemini processing and before paste

### Model Selection

- In **Settings > Model Selection**, pick your Gemini model:
  - `gemini-flash-lite-latest` (default, lower cost)
  - `gemini-flash-latest` (higher quality, higher cost)
- The selected model is used for all new recordings until changed

### Local Mode Setup (Ollama + whisper.cpp)

Use this to process voice entirely on your machine — no API key, no data sent to the cloud.

#### 1. Install Ollama

Download and install [Ollama](https://ollama.com), then pull a model:

```bash
ollama pull llama3.2
```

#### 2. Build whisper.cpp

The local backend uses [whisper.cpp](https://github.com/ggml-org/whisper.cpp) for on-device transcription.

```bash
# Clone whisper.cpp into the backend lib directory
git clone https://github.com/ggml-org/whisper.cpp backend/lib/whisper.cpp
cd backend/lib/whisper.cpp

# Download the English medium model
sh ./models/download-ggml-model.sh medium.en

# Build
cmake -B build
cmake --build build -j --config Release
```

The backend expects the binary at `backend/lib/whisper.cpp/build/bin/whisper-cli` and the model at `backend/lib/whisper.cpp/models/ggml-medium.en.bin`.

#### 3. Start the local backend

```bash
cd backend
bundle install
ruby server.rb
```

The server starts on `http://127.0.0.1:11435`. Verify it:

```bash
curl http://localhost:11435/health
# {"status":"ok"}
```

You can optionally point to a remote Ollama instance:

```bash
OLLAMA_BASE=http://my-server:11434 ruby server.rb
```

#### 4. Switch the app to Local mode

Open **Settings → LLM Provider** and select **Local (Ollama)**. Set the backend URL (`http://localhost:11435` by default) and the model name (`llama3.2` by default). No API key is required.

### Settings (Current)

- **LLM Provider**
  - Switch between **Gemini (Cloud)** and **Local (Ollama)**
  - No restart required; takes effect on the next recording
- **Output**
  - Gen Z mode toggle
- **Text Expansion**
  - Phrase expansion toggle
- **Gemini** *(shown when Gemini is selected)*
  - API key save/view (stored in macOS Keychain)
  - Model selector
- **Local (Ollama)** *(shown when Ollama is selected)*
  - Backend URL (default: `http://localhost:11435`)
  - Model name (default: `llama3.2`)
- **Global Hotkeys**
  - Enable/disable and remap Start, Stop, and Hold hotkeys
- **Permissions**
  - Microphone + Accessibility status with quick links to system settings
- **Updates**
  - Check for updates button + version display

---

## Project Structure

```
open_yapper/
├── lib/
│   ├── main.dart              # App entry, navigation, hotkey wiring
│   ├── screens/               # History, Dictionary, User Info, Stats, Customization, Settings
│   ├── services/              # Recording, Gemini, Ollama, dictionary, profile, phrase expansion, settings
│   ├── views/                 # Onboarding flow
│   └── widgets/               # Reusable UI components
├── backend/                   # Ruby/Sinatra local backend (Ollama + whisper.cpp bridge)
│   ├── server.rb              # API server (port 11435)
│   └── Gemfile                # Ruby dependencies
├── macos/                     # macOS native code (hotkeys, permissions)
├── android/                   # Android config
├── ios/                       # iOS config
├── web/                       # Web build
├── open_yapper_site/          # Next.js landing page (www.openyapper.com)
└── assets/                    # Icons, fonts, images
```

---

## Configuration

- **LLM provider** — Switch between Gemini (cloud) and Local (Ollama) in Settings > LLM Provider
- **Hotkeys** — Enable/disable + remap start, stop, and hold shortcuts in Settings
- **Tone** — Choose casual, normal, informal, or formal per app in Customization
- **Advanced app prompts** — Add per-app writing instructions in Customization (Advanced mode)
- **Gen Z mode** — Toggle in Settings > Output
- **Phrase expansion** — Toggle in Settings > Text Expansion
- **Model** — Select Gemini model in Settings > Model Selection (Gemini mode), or set Ollama model name (local mode)
- **Dictionary & aliases** — Configure replacements in Dictionary and User Info

---

## License

This project is licensed under the **Apache License 2.0**.

---

**Open Yapper** — The GEN Z voice dictation app. Stop typing, start yapping. 🎤
