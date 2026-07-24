import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_types.dart';
import 'gemini_provider.dart' show AiException;

/// Anthropic Claude(Messages API) 제공자.
///
/// `.env` 에서 AI_PROVIDER=claude + ANTHROPIC_API_KEY(+선택 ANTHROPIC_MODEL) 설정 시
/// [AiService] 가 이 제공자를 고른다. 인터페이스만 맞추므로 화면 코드는 그대로.
class ClaudeProvider implements AiProvider {
  ClaudeProvider({required this.apiKey, required this.model, http.Client? client})
      : _client = client ?? http.Client();

  final String apiKey;
  final String model;
  final http.Client _client;

  static final Uri _endpoint = Uri.parse('https://api.anthropic.com/v1/messages');

  @override
  bool get isLive => apiKey.isNotEmpty;

  @override
  Future<AiReply> generate({
    required String systemPrompt,
    required List<AiMessage> history,
  }) async {
    // Anthropic: system 은 별도 필드, messages 는 user/assistant 만.
    final messages = <Map<String, String>>[
      for (final m in history)
        {
          'role': m.role == AiRole.user ? 'user' : 'assistant',
          'content': m.text,
        },
    ];
    final body = {
      'model': model,
      'max_tokens': 500,
      'temperature': 0.9,
      'system': systemPrompt,
      'messages': messages,
    };

    final res = await _client
        .post(
          _endpoint,
          headers: {
            'content-type': 'application/json',
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
          },
          body: jsonEncode(body),
        )
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw AiException('응답이 지연되고 있어요'),
        );

    if (res.statusCode != 200) {
      throw AiException('AI 응답 오류 (${res.statusCode})');
    }

    final decoded =
        jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    // content 는 블록 배열: [{type:'text', text:'...'}, ...]
    final content = decoded['content'] as List<dynamic>?;
    final text = (content ?? [])
        .whereType<Map>()
        .where((b) => b['type'] == 'text')
        .map((b) => b['text'] as String? ?? '')
        .join()
        .trim();
    if (text.isEmpty) throw AiException('답변이 비어 있어요');

    return AiReply(text: text);
  }
}
