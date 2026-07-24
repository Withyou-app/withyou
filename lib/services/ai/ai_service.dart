import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/mind_report.dart';
import '../auth_service.dart';
import 'ai_personas.dart';
import 'ai_types.dart';
import 'claude_provider.dart';
import 'demo_provider.dart';
import 'gemini_provider.dart';
import 'openai_provider.dart';

/// AI 대화의 단일 진입점. 화면은 이 서비스만 알면 되고, 실제 제공자
/// (Gemini/Claude/데모)는 여기서 .env 설정에 따라 선택한다.
///
/// 지금은 Gemini, 추후 ANTHROPIC_API_KEY 채우고 AI_PROVIDER=claude 로 바꾸면
/// ClaudeProvider 만 추가해 교체할 수 있다(화면 코드는 그대로).
class AiService {
  AiService._();
  static final AiService instance = AiService._();

  late final AiProvider _provider;
  bool _initialized = false;

  /// 실제 원격 AI 가 연결됐는지(키가 있는지). 데모면 false.
  bool get isLive => _provider.isLive;

  /// main() 에서 1회 호출. .env 를 읽어 제공자를 고른다.
  void init() {
    if (_initialized) return;
    _provider = _selectProvider();
    _initialized = true;
  }

  AiProvider _selectProvider() {
    final provider = (dotenv.maybeGet('AI_PROVIDER') ?? 'gemini').trim();
    switch (provider) {
      case 'gemini':
        final key = (dotenv.maybeGet('GEMINI_API_KEY') ?? '').trim();
        if (key.isEmpty) return DemoProvider();
        return GeminiProvider(
          apiKey: key,
          model: (dotenv.maybeGet('GEMINI_MODEL') ?? 'gemini-2.5-flash').trim(),
        );
      case 'openai':
      case 'gpt':
        final key = (dotenv.maybeGet('OPENAI_API_KEY') ?? '').trim();
        if (key.isEmpty) return DemoProvider();
        return OpenAiProvider(
          apiKey: key,
          model: (dotenv.maybeGet('OPENAI_MODEL') ?? 'gpt-4o-mini').trim(),
        );
      case 'claude':
      case 'anthropic':
        final key = (dotenv.maybeGet('ANTHROPIC_API_KEY') ?? '').trim();
        if (key.isEmpty) return DemoProvider();
        return ClaudeProvider(
          apiKey: key,
          model: (dotenv.maybeGet('ANTHROPIC_MODEL') ?? 'claude-sonnet-5').trim(),
        );
      default:
        return DemoProvider();
    }
  }

  /// [persona] 페르소나로 [history] 에 이어질 다음 응답을 만든다.
  /// 선물 추천 마커는 여기서 파싱해 [AiReply.recommendGift] 로 바꾸고 본문에서 제거한다.
  Future<AiReply> reply({
    required String persona,
    required List<AiMessage> history,
  }) async {
    final systemPrompt = buildSystemPrompt(
      persona: persona,
      user: AuthService.instance.currentUser,
    );
    final raw = await _provider.generate(
      systemPrompt: systemPrompt,
      history: history,
    );
    return _extractGiftSignal(raw);
  }

  /// 대화 종료 시 마음 리포트(감정 태그 + 요약)를 생성한다.
  /// 실제 제공자면 JSON 응답을 파싱하고, 데모/실패 시 휴리스틱 리포트로 대체한다.
  Future<MindReport> generateReport({
    required String persona,
    required List<AiMessage> history,
    required String createdAt,
  }) async {
    if (_provider.isLive) {
      try {
        final raw = await _provider.generate(
          systemPrompt: buildReportPrompt(persona: persona),
          history: [
            ...history,
            const AiMessage(role: AiRole.user, text: '지금까지의 대화를 리포트로 정리해줘.'),
          ],
        );
        final parsed = _tryParseReport(raw.text);
        if (parsed != null) {
          return MindReport(
            persona: persona,
            emotions: (parsed['emotions'] as List).cast<String>(),
            summary: parsed['summary'] as String,
            needNow: parsed['needNow'] as String,
            smallAction: parsed['smallAction'] as String,
            mission: parsed['mission'] as String,
            createdAt: createdAt,
          );
        }
      } catch (_) {
        // 실패 시 아래 휴리스틱으로.
      }
    }
    return _demoReport(persona, history, createdAt);
  }

  /// 모델 텍스트에서 JSON 을 추출해 리포트 필드로 파싱. 실패 시 null.
  Map<String, dynamic>? _tryParseReport(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    try {
      final map =
          jsonDecode(text.substring(start, end + 1)) as Map<String, dynamic>;
      final emotions = (map['emotions'] as List?)?.cast<String>() ?? const [];
      final summary = (map['summary'] as String?)?.trim() ?? '';
      if (emotions.isEmpty && summary.isEmpty) return null;
      return {
        'emotions': emotions.take(3).toList(),
        'summary': summary,
        'needNow': (map['needNow'] as String?)?.trim() ?? '',
        'smallAction': (map['smallAction'] as String?)?.trim() ?? '',
        'mission': (map['mission'] as String?)?.trim() ?? '',
      };
    } catch (_) {
      return null;
    }
  }

  /// 데모/폴백 리포트 — 사용자 메시지에서 감정을 대략 추정.
  MindReport _demoReport(
      String persona, List<AiMessage> history, String createdAt) {
    const sad = ['힘들', '지쳐', '슬퍼', '우울', '외로', '속상', '불안', '걱정', '화나', '짜증'];
    final userText =
        history.where((m) => m.role == AiRole.user).map((m) => m.text).join(' ');
    final isSad = sad.any(userText.contains);
    return MindReport(
      persona: persona,
      emotions: isSad ? const ['속상함', '지침'] : const ['평온', '일상'],
      summary: isSad
          ? '오늘은 마음이 조금 지치고 속상했던 하루였어요. $persona와 그 마음을 나눴어요.'
          : '$persona와 오늘 하루의 이야기를 편안하게 나눴어요.',
      needNow: isSad ? '잠시 나를 다독여줄 휴식이 필요해 보여요.' : '지금의 편안함을 이어가면 좋겠어요.',
      smallAction: isSad ? '따뜻한 물 한 잔 마시고 크게 숨을 내쉬어 보세요.' : '오늘 기분 좋았던 순간 하나를 떠올려 보세요.',
      mission: isSad ? '자기 전에 오늘 나에게 수고했다고 한마디 건네보기.' : '내일 하고 싶은 작은 일 하나 적어보기.',
      createdAt: createdAt,
    );
  }

  /// 본문에 섞여 온 선물 마커(`<<GIFT:선물명>>` 또는 `<<GIFT>>`)를 신호로 분리하고,
  /// 표시 텍스트에서는 제거한다. 선물명이 있으면 [AiReply.giftName] 에 담는다.
  AiReply _extractGiftSignal(AiReply reply) {
    if (!reply.text.contains(kGiftMarker)) {
      return reply.recommendGift
          ? AiReply(text: reply.text, recommendGift: true, giftName: reply.giftName)
          : reply;
    }
    // "<<GIFT:케이크>>" / "<<GIFT: 케이크" / "<<GIFT>>" 모두 처리.
    final match = RegExp('${RegExp.escape(kGiftMarker)}\\s*:?\\s*([^\\n>]*)')
        .firstMatch(reply.text);
    final gift = match?.group(1)?.replaceAll('>', '').trim();
    final cleaned = reply.text
        .replaceAll(RegExp('${RegExp.escape(kGiftMarker)}[^\\n]*'), '')
        .trim();
    return AiReply(
      text: cleaned,
      recommendGift: true,
      giftName: (gift == null || gift.isEmpty) ? null : gift,
    );
  }
}
