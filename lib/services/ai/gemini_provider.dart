import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_types.dart';

/// Google Gemini(Generative Language API) 제공자.
///
/// 추후 Claude 로 교체할 때는 이 클래스 대신 ClaudeProvider 를 구현해
/// [AiService] 선택 로직에 연결하면 되고, 대화 화면 코드는 바뀌지 않는다.
class GeminiProvider implements AiProvider {
  GeminiProvider({required this.apiKey, required this.model, http.Client? client})
      : _client = client ?? http.Client();

  final String apiKey;
  final String model;
  final http.Client _client;

  @override
  bool get isLive => apiKey.isNotEmpty;

  Uri get _endpoint => Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        '$model:generateContent?key=$apiKey',
      );

  @override
  Future<AiReply> generate({
    required String systemPrompt,
    required List<AiMessage> history,
  }) async {
    final body = {
      'system_instruction': {
        'parts': [
          {'text': systemPrompt}
        ]
      },
      'contents': [
        for (final m in history)
          {
            'role': m.role == AiRole.user ? 'user' : 'model',
            'parts': [
              {'text': m.text}
            ],
          }
      ],
      'generationConfig': {
        'temperature': 0.9,
        'topP': 0.95,
        'maxOutputTokens': 500,
        // 2.5 계열은 기본 'thinking'이 켜져 출력이 잘릴 수 있어 끈다(빠른 대화용).
        'thinkingConfig': {'thinkingBudget': 0},
      },
    };

    final res = await _client.post(
      _endpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw AiException('AI 응답 오류 (${res.statusCode})');
    }

    final decoded = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      // 안전 필터 등으로 후보가 비어있는 경우.
      throw AiException('답변을 만들지 못했어요');
    }
    final parts = (((candidates.first as Map)['content'] as Map?)?['parts']
        as List<dynamic>?);
    final text = (parts ?? [])
        .map((p) => (p as Map)['text'] as String? ?? '')
        .join()
        .trim();
    if (text.isEmpty) throw AiException('답변이 비어 있어요');

    return AiReply(text: text);
  }
}

/// AI 호출 중 발생하는 에러. 화면에서 사용자 친화 메시지로 안내한다.
class AiException implements Exception {
  AiException(this.message);
  final String message;
  @override
  String toString() => message;
}
