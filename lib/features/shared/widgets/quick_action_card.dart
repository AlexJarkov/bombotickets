import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);

    return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(res.wp(4)),
          child: Container(
            padding: EdgeInsets.all(res.wp(4)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(res.wp(4)),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: res.dp(4), color: color),
                SizedBox(height: res.hp(1)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: res.dp(1.8),
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: res.hp(0.5)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: res.dp(1.4),
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: 100.ms)
        .slideY(begin: 0.2, duration: 300.ms, delay: 100.ms)
        .shimmer(delay: 800.ms, duration: 1000.ms);
  }
}
