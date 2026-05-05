import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.12),
      highlightColor: Colors.white.withValues(alpha: 0.28),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _bar(220, 28),
          const SizedBox(height: 20),
          _bar(double.infinity, 200),
          const SizedBox(height: 16),
          _bar(double.infinity, 80),
          const SizedBox(height: 16),
          _bar(double.infinity, 130),
          const SizedBox(height: 16),
          _bar(double.infinity, 220),
        ],
      ),
    );
  }

  Widget _bar(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      );
}
