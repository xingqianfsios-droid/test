import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade800,
              Colors.red.shade900,
              Colors.brown.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              // 标题
              const Text(
                '象棋',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 16,
                  shadows: [
                    Shadow(
                      blurRadius: 12,
                      color: Colors.black54,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Xiangqi Pro',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 4,
                ),
              ),
              const Spacer(flex: 3),
              // 开始游戏按钮
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      elevation: 6,
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    onPressed: () => Get.offNamed('/game'),
                    child: const Text('开始游戏'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 游戏规则按钮
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    onPressed: () => _showRulesDialog(context),
                    child: const Text('游戏规则'),
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

  void _showRulesDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.menu_book, color: Colors.brown),
            SizedBox(width: 8),
            Text('象棋规则'),
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
              Divider(),
              _RuleSection(title: '胜负判定', content: '将对方的帅/将吃掉或使其无路可走（绝杀/困毙）即获胜。'),
              _RuleSection(title: '倒计时', content: '每步棋有30秒的思考时间。倒计时10秒时会有声音提示，超时系统将自动帮你走一步棋。'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('知道了'),
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
          style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          children: [
            TextSpan(
              text: '$title：',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            TextSpan(text: content),
          ],
        ),
      ),
    );
  }
}
