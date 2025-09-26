import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!isLoading) return child;

    final baseCol =
        baseColor ?? (isDark ? Colors.grey[800]! : Colors.grey[300]!);
    final highlightCol =
        highlightColor ?? (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    return child
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: duration, colors: [baseCol, highlightCol, baseCol]);
  }
}

// Componentes de shimmer predefinidos
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class ShimmerText extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerText({super.key, this.width = 100, this.height = 16});

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(width: width, height: height, borderRadius: height / 2);
  }
}

class ShimmerCircle extends StatelessWidget {
  final double diameter;

  const ShimmerCircle({super.key, this.diameter = 40});

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: diameter,
      height: diameter,
      borderRadius: diameter / 2,
    );
  }
}

// Card de shimmer para lista de tickets
class TicketShimmerCard extends StatelessWidget {
  const TicketShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ShimmerCircle(diameter: 50),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerText(width: 150, height: 18),
                      const SizedBox(height: 4),
                      const ShimmerText(width: 100, height: 14),
                    ],
                  ),
                ),
                const ShimmerBox(width: 60, height: 24, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 16),
            const ShimmerText(width: double.infinity, height: 14),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ShimmerText(width: 80, height: 14),
                const ShimmerText(width: 100, height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Profile shimmer
class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      isLoading: true,
      child: Column(
        children: [
          const SizedBox(height: 40),
          const ShimmerCircle(diameter: 100),
          const SizedBox(height: 16),
          const ShimmerText(width: 120, height: 20),
          const SizedBox(height: 8),
          const ShimmerText(width: 160, height: 16),
          const SizedBox(height: 32),
          ...List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const ShimmerBox(width: 24, height: 24, borderRadius: 4),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: ShimmerText(width: double.infinity, height: 16),
                  ),
                  const ShimmerBox(width: 20, height: 20, borderRadius: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Lista de shimmer genérica
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final Widget Function(int index) itemBuilder;
  final EdgeInsets? padding;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    required this.itemBuilder,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) =>
          ShimmerLoading(isLoading: true, child: itemBuilder(index)),
    );
  }
}
