import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_types.dart';
import 'gemini_provider.dart' show AiException;

/// OpenAI(Chat Completions) 제공자. Gemini 대신 임시로 GPT 키를 쓸 때 사용.
///
/// `.env` 에서 AI_PROVIDER=openai + OPENAI_API_KEY(+선택 OPENAI_MODEL) 설정 시
/// [AiService] 가 이 제공자를 고른다. 인터페이스만 맞추므로 화면 코드는 그대로.
class OpenAiProvider implements AiProvider {
  OpenAiProvider({required this.apiKey, required this.model, http.Client? client})
      : _client = client ?? http.Client();

  final String apiKey;
  final String model;
  final http.Client _client;

  static final Uri _endpoint =
      Uri.parse('https://api.openai.com/v1/chat/completions');

  @override
  bool get isLive => apiKey.isNotEmpty;

  @override
  Future<AiReply> generate({
    required String systemPrompt,
    required List<AiMessage> history,
  }) async {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      for (final m in history)
        {
          'role': m.role == AiRole.user ? 'user' : 'assistant',
          'content': m.text,
        },
    ];
    final body = {
      'model': model,
      'messages': messages,
      'temperature': 0.9,
      'max_tokens': 500,
    };

    final res = await _client
        .post(
          _endpoint,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode(body),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw AiException('응답이 지연되고 있어요'),
        );

    if (res.statusCode != 200) {
      throw AiException('AI 응답 오류 (${res.statusCode})');
    }

    final decoded =
        jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw AiException('답변을 만들지 못했어요');
    }
    final text = ((choices.first as Map)['message']
                as Map<String, dynamic>?)?['content'] as String? ??
        '';
    if (text.trim().isEmpty) throw AiException('답변이 비어 있어요');

    return AiReply(text: text.trim());
  }
}
