import 'dart:ui';

import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double blur;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.radius = 24,
    // sigma=4: with ~8 cards on screen each running its own BackdropFilter,
    // every sigma point is real GPU time. 4 still reads as frosted glass.
    this.blur = 4,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Light: bright frosted glass; Dark: deep smoked glass. The shift between
    // these is what gives the user a visible signal when toggling theme.
    final overlayColor = isDark
        ? Colors.black.withValues(alpha: 0.30)
        : Colors.white.withValues(alpha: 0.20);

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.40);

    return Container(
      margin: margin,
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(radius),
                // Plain Container — MaterialApp already cross-fades between
                // light/dark ThemeData (~200ms), so per-card AnimatedContainer
                // was redundant work, multiplied by every visible card.
                child: Container(
                  decoration: BoxDecoration(
                    color: overlayColor,
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(color: borderColor),
                  ),
                  padding: padding,
                  // Default text inside any GlassCard gets a soft halo so it
                  // stays legible on every mood gradient. Explicit shadows on
                  // a Text's own style still win.
                  child: DefaultTextStyle.merge(
                    style: const TextStyle(
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Color(0x40000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
