require 'sinatra'
require 'ruby_llm'
require 'json'
require 'fileutils'

OLLAMA_BASE = ENV.fetch('OLLAMA_BASE', 'http://localhost:11434')

WHISPER_DIR  = File.join(__dir__, 'lib', 'whisper.cpp')
WHISPER_BIN  = File.join(WHISPER_DIR, 'build', 'bin', 'whisper-cli')
WHISPER_MODEL = ENV.fetch('WHISPER_MODEL', File.join(WHISPER_DIR, 'models', 'ggml-medium.en.bin'))

set :port, 11435
set :bind, '127.0.0.1'

RubyLLM.configure do |c|
  c.ollama_api_base = "#{OLLAMA_BASE}/v1"
end

before do
  content_type :json
end

get '/health' do
  { status: 'ok' }.to_json
end

post '/process_audio' do
  audio_file = params[:audio]
  system_prompt = params[:system_prompt] || ''
  model_param = params[:model] || 'llama3.2'

  unless audio_file
    halt 400, { error: 'Missing audio file' }.to_json
  end

  audio_path = audio_file[:tempfile].path

  begin
    transcript = transcribe_audio(audio_path)

    pp transcript
  rescue => e
    warn "[process_audio] Transcription error: #{e.class}: #{e.message}"
    halt 502, { error: "Transcription failed: #{e.message}" }.to_json
  end

  if transcript.nil? || transcript.strip.empty?
    halt 422, { error: 'Transcription returned empty text' }.to_json
  end

  begin
    clean_model = model_param.sub(/^ollama\//, '')
    chat = RubyLLM.chat(model: clean_model, provider: :ollama, assume_model_exists: true)
    result = chat.ask("#{system_prompt}\n\nUser said: #{transcript}")
    pp result.content
    { text: result.content }.to_json
  rescue => e
    halt 502, { error: "LLM processing failed: #{e.message}" }.to_json
  end
end

post '/process_text' do
  request.body.rewind
  body = JSON.parse(request.body.read) rescue {}
  transcription = body['transcription'] || ''
  system_prompt = body['system_prompt'] || ''
  model_param = body['model'] || 'llama3.2'

  if transcription.strip.empty?
    halt 400, { error: 'Missing transcription' }.to_json
  end

  begin
    clean_model = model_param.sub(/^ollama\//, '')
    chat = RubyLLM.chat(model: clean_model, provider: :ollama, assume_model_exists: true)
    result = chat.ask("#{system_prompt}\n\nUser said: #{transcription}")
    { text: result.content }.to_json
  rescue => e
    halt 502, { error: "LLM processing failed: #{e.message}" }.to_json
  end
end

def transcribe_audio(file_path)
  require 'open3'
  require 'tmpdir'

  output_dir = Dir.mktmpdir('whisper_')
  wav_path = File.join(output_dir, 'audio.wav')

  begin
    # whisper-cpp requires 16kHz mono WAV
    _, err, st = Open3.capture3('ffmpeg', '-y', '-i', file_path, '-ar', '16000', '-ac', '1', wav_path)
    raise "ffmpeg conversion failed: #{err}" unless st.success?

    _, err, st = Open3.capture3(WHISPER_BIN, '--model', WHISPER_MODEL, '--output-txt', wav_path)

    raise "whisper-cpp failed: #{err}" unless st.success?

    txt_path = "#{wav_path}.txt"
    raise 'whisper-cpp produced no output file' unless File.exist?(txt_path)

    File.read(txt_path).strip
  ensure
    FileUtils.remove_entry(output_dir)
  end
end
