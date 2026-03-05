import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 古风色彩常量
const _kParchment = Color(0xFFF5E6C8);
const _kInk = Color(0xFF3C2415);
const _kGold = Color(0xFF8B6914);
const _kGoldLight = Color(0xFFD4A84B);
const _kBamboo = Color(0xFFE8D5B0);

/// 按钮主色：深朱红（主按钮）
const _kBtnPrimary = Color(0xFFC0392B);
const _kBtnPrimaryDark = Color(0xFF922B21);
const _kBtnPrimaryLight = Color(0xFFE74C3C);

/// 按钮次色：描金镂空（次按钮）
const _kBtnOutlineBorder = Color(0xFFD4A84B);
const _kBtnOutlineText = Color(0xFFD4A84B);

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C1810),
              Color(0xFF3C2415),
              Color(0xFF2C1810),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 顶部装饰线
              _buildDivider(),
              const SizedBox(height: 32),

              // 标题
              const Text(
                '象 棋',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                  color: _kGoldLight,
                  letterSpacing: 24,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      blurRadius: 20,
                      color: Color(0x80D4A84B),
                      offset: Offset(0, 2),
                    ),
                    Shadow(
                      blurRadius: 4,
                      color: Color(0xFF1A0E08),
                      offset: Offset(2, 3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '- 楚 河 汉 界 -',
                style: TextStyle(
                  fontSize: 15,
                  color: _kBamboo.withValues(alpha: 0.6),
                  letterSpacing: 8,
                ),
              ),

              const SizedBox(height: 32),
              _buildDivider(),

              const Spacer(flex: 3),

              // 开始游戏按钮（主按钮：深朱红渐变 + 金边 + 大阴影）
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: _PrimaryButton(
                  label: '开始对弈',
                  onPressed: () => Get.toNamed('/game'),
                ),
              ),
              const SizedBox(height: 16),
              // 游戏规则按钮（次按钮：描金镂空）
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: _SecondaryButton(
                  label: '棋谱规则',
                  onPressed: () => _showRulesDialog(context),
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _kGoldLight.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _kGoldLight,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _kGoldLight.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRulesDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: _kParchment,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _kGold, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.auto_stories, color: _kGold),
            SizedBox(width: 8),
            Text('棋谱规则', style: TextStyle(color: _kInk)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _RuleSection(title: '帅/将', content: '只能在九宫格内移动（3x3区域），每步上下左右走一格。两方的帅和将不能在同一列上直接对面（中间无棋子阻隔）。'),
              _RuleSection(title: '仕/士', content: '只能在九宫格内沿斜线移动，每步走一格。'),
              _RuleSection(title: '相/象', content: '沿对角线走"田"字（两格），不能越过河界到对方阵地。如果"田"字中心有棋子（塞象眼），则不能走。'),
              _RuleSection(title: '马', content: '走"日"字，先直走一格再斜走一格。如果直走方向有棋子（别马腿/蹩马腿），则不能走该方向。'),
              _RuleSection(title: '车', content: '横竖直线任意移动，不能越过其他棋子。可以吃路径上第一个遇到的对方棋子。'),
              _RuleSection(title: '炮', content: '移动方式与车相同（直线）。但吃子时必须翻过恰好一个棋子（炮架），吃掉炮架后面的第一个对方棋子。'),
              _RuleSection(title: '兵/卒', content: '未过河前只能向前走一步。过河后可以向前、向左或向右走一步，但不能后退。'),
              Divider(color: _kGold),
              _RuleSection(title: '胜负判定', content: '将对方的帅/将吃掉或使其无路可走（绝杀/困毙）即获胜。'),
              _RuleSection(title: '倒计时', content: '每步棋有30秒的思考时间。倒计时10秒时会有声音提示，超时系统将自动帮你走一步棋。'),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: _kBtnPrimary,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            onPressed: () => Get.back(),
            child: const Text('知晓'),
          ),
        ],
      ),
    );
  }
}

/// 主按钮：深朱红渐变背景 + 金边描边 + 阴影
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _PrimaryButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kBtnPrimaryLight, _kBtnPrimary, _kBtnPrimaryDark],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kBtnOutlineBorder, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x60922B21),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Color(0x30000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: _kParchment,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
          ),
          onPressed: onPressed,
          child: Text(label),
        ),
      ),
    );
  }
}

/// 次按钮：金色描边镂空
class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _SecondaryButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: _kBtnOutlineText,
          side: const BorderSide(color: _kBtnOutlineBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: const Color(0x15D4A84B),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class _RuleSection extends StatelessWidget {
  final String title;
  final String content;

  const _RuleSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Color(0xFF5C3A1E), height: 1.6),
          children: [
            TextSpan(
              text: '$title：',
              style: const TextStyle(fontWeight: FontWeight.bold, color: _kGold),
            ),
            TextSpan(text: content),
          ],
        ),
      ),
    );
  }
}
