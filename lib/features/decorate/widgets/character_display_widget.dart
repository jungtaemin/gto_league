import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:math' as math;

/// A high-quality character display widget using Flutter's rendering capabilities.
/// Renders GTO Robot (Sci-Fi) or Ninja Girl (Cyberpunk) without image assets.
class CharacterDisplayWidget extends StatefulWidget {
  final String characterId;
  final double size;
  final bool isLocked;
  final String? assetUrl;

  const CharacterDisplayWidget({
    super.key,
    required this.characterId,
    this.size = 200,
    this.isLocked = false,
    this.assetUrl,
  });

  @override
  State<CharacterDisplayWidget> createState() => _CharacterDisplayWidgetState();
}

class _CharacterDisplayWidgetState extends State<CharacterDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLocked) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.3,
              child: _buildCharacterContent(),
            ),
            Icon(Icons.lock, size: widget.size * 0.4, color: Colors.white54),
          ],
        ),
      );
    }
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: _buildCharacterContent(),
    );
  }

  Widget _buildCharacterContent() {
    // If we have an exact asset URL provided (for example from preview item)
    String effectiveUrl = widget.assetUrl ?? 'assets/images/characters/${widget.characterId}.png';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Subtle floating movement (-5px to +5px vertically)
        final offsetY = math.sin(_controller.value * math.pi) * 5.0;

        return Transform.translate(
          offset: Offset(0, offsetY),
          child: Image.asset(
            effectiveUrl,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
               return Icon(Icons.person_outline, size: widget.size * 0.7, color: Colors.white54);
            },
          ),
        );
      },
    );
  }
}
