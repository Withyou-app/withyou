import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../services/auth_service.dart';

/// 프로필 수정 — 호칭/자기소개/취향/알레르기/향을 수정하고 저장한다.
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  // 호칭(이름)은 마이페이지에서 인라인으로 수정하므로 여기서는 다루지 않는다.
  late final TextEditingController _bio;
  late final TextEditingController _humor;
  late final TextEditingController _gift;
  late final TextEditingController _allergy;
  late final TextEditingController _scent;

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser;
    _bio = TextEditingController(text: user?.bio ?? '');
    _humor = TextEditingController(text: user?.humor ?? '');
    _gift = TextEditingController(text: user?.giftTaste ?? '');
    _allergy = TextEditingController(text: user?.allergy ?? '');
    _scent = TextEditingController(text: user?.scent ?? '');
  }

  @override
  void dispose() {
    _bio.dispose();
    _humor.dispose();
    _gift.dispose();
    _allergy.dispose();
    _scent.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    await AuthService.instance.updateProfile(
      user.copyWith(
        bio: _bio.text.trim(),
        humor: _humor.text.trim(),
        giftTaste: _gift.text.trim(),
        allergy: _allergy.text.trim(),
        scent: _scent.text.trim(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('프로필이 저장되었어요')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardAwareForm(
        header: const BackHeader(title: '프로필 수정'),
        action: PrimaryButton(label: '저장', onPressed: _save),
        children: [
          LabeledTextField(
            label: '자기소개',
            hint: '자기소개를 간단하게 입력해주세요',
            controller: _bio,
            maxLines: 3,
          ),
          AppGaps.v20,
          LabeledTextField(
            label: '유머 취향',
            hint: 'ex) 아이러니, 블랙 코미디, 슬랩스틱',
            controller: _humor,
          ),
          AppGaps.v20,
          LabeledTextField(
            label: '선물 취향',
            hint: 'ex) 소품, 향초, 디저트',
            controller: _gift,
          ),
          AppGaps.v20,
          LabeledTextField(
            label: '알레르기',
            hint: 'ex) 견과류, 새우, 없음',
            controller: _allergy,
          ),
          AppGaps.v20,
          LabeledTextField(
            label: '선호하는 향',
            hint: 'ex) 우디, 시트러스, 플로럴',
            controller: _scent,
          ),
        ],
      ),
    );
  }
}
