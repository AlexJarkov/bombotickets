import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';

class AppShimmer extends StatelessWidget {
  final Widget child;
  final bool enabled;
  final Color? baseColor;
  final Color? highlightColor;

  const AppShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!enabled) return child;

    return Shimmer.fromColors(
      baseColor: baseColor ?? theme.colorScheme.surface,
      highlightColor:
          highlightColor ?? theme.colorScheme.onSurface.withOpacity(0.1),
      child: child,
    );
  }
}

// Widget específico para cards de carga
class ShimmerCard extends StatelessWidget {
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? margin;

  const ShimmerCard({super.key, this.height, this.width, this.margin});

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final theme = Theme.of(context);

    return Container(
      height: height ?? res.hp(20),
      width: width,
      margin: margin ?? EdgeInsets.all(res.wp(2)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(res.wp(4)),
      ),
      child: AppShimmer(
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(res.wp(4)),
          ),
        ),
      ),
    );
  }
}

// Widget para simular lista de shimmer
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);

    return ListView.builder(
      padding: padding ?? EdgeInsets.all(res.wp(4)),
      itemCount: itemCount,
      itemBuilder: (context, index) => ShimmerCard(
        height: itemHeight,
        margin: EdgeInsets.only(bottom: res.hp(2)),
      ),
    );
  }
}
