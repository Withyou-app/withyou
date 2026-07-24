import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:withyou/app.dart';

void main() {
  testWidgets('로그인 화면이 렌더링된다', (WidgetTester tester) async {
    await tester.pumpWidget(const WithYouApp());

    // 브랜드는 텍스트 대신 로고 이미지로 표시된다.
    expect(find.byType(Image), findsWidgets);
    expect(find.text('당신만의 AI 감정친구'), findsOneWidget);
    expect(find.text('로그인'), findsWidgets);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
