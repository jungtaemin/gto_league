import 'package:flutter/material.dart';

/// Stitch V1 Right Menu: Colored gradient buttons (achievements + mail)
class GtoRightMenu extends StatelessWidget {
  const GtoRightMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(Icons.emoji_events, "업적", const Color(0xFF3B82F6), const Color(0xFF2563EB), const Color(0xFF93C5FD)),
        const SizedBox(height: 12),
        _buildButton(Icons.mail, "우편함", const Color(0xFF22D3EE), const Color(0xFF0891B2), const Color(0xFF67E8F9)),
      ],
    );
  }

  Widget _buildButton(IconData icon, String label, Color colorTop, Color colorBottom, Color borderColor) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colorTop, colorBottom],
              ),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(color: colorBottom.withOpacity(0.5), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20, shadows: const [Shadow(color: Colors.black38, blurRadius: 4)]),
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Jua',
                  shadows: [Shadow(color: Colors.black26, blurRadius: 2)])),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
