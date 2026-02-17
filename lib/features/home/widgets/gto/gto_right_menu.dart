import 'package:flutter/material.dart';

/// Stitch V2 Right Menu: Blue/Cyan Gradient Buttons (Achievements + Mail)
class GtoRightMenu extends StatelessWidget {
  const GtoRightMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Achievements: Blue-400 to Blue-600
        _buildButton(
          icon: Icons.emoji_events,
          label: "업적",
          gradientColors: const [Color(0xFF60A5FA), Color(0xFF2563EB)], // blue-400 -> blue-600
          borderColor: const Color(0xFF93C5FD), // blue-300
          onTap: () {
            print("Achievements clicked"); // Connection Point
          }
        ),
        const SizedBox(height: 16),
        // Mail: Cyan-400 to Blue-500
        _buildButton(
          icon: Icons.mail,
          label: "우편함",
          gradientColors: const [Color(0xFF22D3EE), Color(0xFF3B82F6)], // cyan-400 -> blue-500
          borderColor: const Color(0xFF67E8F9), // cyan-300
          onTap: () {
            print("Mail clicked"); // Connection Point
          }
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required List<Color> gradientColors,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60, height: 60, // Stitch V2 size
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(color: gradientColors.last.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24, shadows: const [Shadow(color: Colors.black26, blurRadius: 4)]),
            const SizedBox(height: 1),
            Text(label, style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Jua',
              shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
            )),
          ],
        ),
      ),
    );
  }
}
