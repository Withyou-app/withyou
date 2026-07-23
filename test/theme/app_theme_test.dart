import 'package:flutter_test/flutter_test.dart';
import 'package:withyou/theme/app_theme.dart';
import 'package:withyou/theme/app_fonts.dart';

void main() {
  test('앱 테마에 코코초이툰 폰트가 적용된다', () {
    expect(AppTheme.light.textTheme.bodyMedium?.fontFamily,
        AppFonts.cocochoitoon);
  });
}
