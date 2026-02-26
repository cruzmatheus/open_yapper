import 'dart:convert';

import 'package:http/http.dart' as http;

class OllamaService {
  OllamaService({required this.baseUrl, required this.model});

  final String baseUrl;
  final String model;

  Future<String> processAudio({
    required String audioFilePath,
    required String systemPrompt,
  }) async {
    final uri = Uri.parse('$baseUrl/process_audio');
    final request = http.MultipartRequest('POST', uri);
    request.fields['system_prompt'] = systemPrompt;
    request.fields['model'] = model;
    request.files.add(
      await http.MultipartFile.fromPath('audio', audioFilePath),
    );

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 90),
    );
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      final body = _tryDecodeError(response.body);
      throw OllamaException(
        'Backend error (${response.statusCode}): $body',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final text = data['text'] as String?;
    if (text == null || text.isEmpty) {
      throw OllamaException('Backend returned an empty response.');
    }
    return text;
  }

  Future<String> processText({
    required String transcription,
    required String systemPrompt,
  }) async {
    final uri = Uri.parse('$baseUrl/process_text');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'transcription': transcription,
            'system_prompt': systemPrompt,
            'model': model,
          }),
        )
        .timeout(const Duration(seconds: 90));

    if (response.statusCode != 200) {
      final body = _tryDecodeError(response.body);
      throw OllamaException(
        'Backend error (${response.statusCode}): $body',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final text = data['text'] as String?;
    if (text == null || text.isEmpty) {
      throw OllamaException('Backend returned an empty response.');
    }
    return text;
  }

  String _tryDecodeError(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return data['error'] as String? ?? body;
    } catch (_) {
      return body;
    }
  }
}

class OllamaException implements Exception {
  OllamaException(this.message);
  final String message;
  @override
  String toString() => message;
}
