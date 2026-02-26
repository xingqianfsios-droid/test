import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 古风色彩常量
const _kParchment = Color(0xFFF5E6C8);
const _kInk = Color(0xFF3C2415);
const _kGold = Color(0xFF8B6914);
const _kGoldLight = Color(0xFFD4A84B);
const _kBamboo = Color(0xFFE8D5B0);

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

              // 开始游戏按钮
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kGold,
                      foregroundColor: _kParchment,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: _kGoldLight, width: 1),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0x80000000),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                    ),
                    onPressed: () => Get.toNamed('/game'),
                    child: const Text('开始对弈'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 游戏规则按钮
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kBamboo,
                      side: BorderSide(
                        color: _kBamboo.withValues(alpha: 0.4),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                    ),
                    onPressed: () => _showRulesDialog(context),
                    child: const Text('棋谱规则'),
                  ),
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
            onPressed: () => Get.back(),
            child: const Text('知晓'),
          ),
        ],
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
