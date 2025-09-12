import 'package:flutter/material.dart';
import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/features/shared/widgets/glass_card.dart';
import '../entities/real_event.dart';

class RealEventCard extends StatelessWidget {
  final RealEvent event;
  final VoidCallback? onTap;

  const RealEventCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final theme = Theme.of(context);

    return GlassCard(
      margin: EdgeInsets.only(bottom: AppTheme.spacingMedium),
      padding: EdgeInsets.zero,
      borderRadius: AppTheme.borderRadiusNormal,
      animated: true,
      animationDuration: const Duration(milliseconds: 400),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusNormal),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Evitar overflow
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen del evento
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.borderRadiusNormal),
                topRight: Radius.circular(AppTheme.borderRadiusNormal),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: event.imagen != null
                    ? Image.network(
                        event.imagen!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholder(res),
                      )
                    : _buildPlaceholder(res),
              ),
            ),

            // Contenido del evento
            Flexible(
              // Usar Flexible para evitar overflow
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacingNormal),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título y categoría
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            event.nombre,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: AppTheme.spacingSmall),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingSmall,
                            vertical: AppTheme.spacingSmall / 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              event.categoria.nombre,
                            ).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusSmall,
                            ),
                          ),
                          child: Text(
                            event.categoria.nombre,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _getCategoryColor(event.categoria.nombre),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: AppTheme.spacingSmall),

                    // Organizador
                    Text(
                      'Por ${event.organizador.nombre}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.grey1,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: AppTheme.spacingSmall),

                    // Información de ubicación y fecha
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: res.dp(1.6),
                          color: AppTheme.grey1,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${event.lugar}, ${event.ciudad}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.grey1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: AppTheme.spacingSmall / 2),

                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: res.dp(1.6),
                          color: AppTheme.grey1,
                        ),
                        SizedBox(width: 4),
                        Text(
                          event.fecha,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.grey1,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${event.maxTickets} tickets máx.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.grey1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: AppTheme.spacingNormal),

                    // Botón de acción
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: AppTheme.spacingSmall,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusSmall,
                            ),
                          ),
                        ),
                        child: Text(
                          'Ver Detalles',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Responsive res) {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
      child: Icon(Icons.event_rounded, size: res.dp(4), color: Colors.white),
    );
  }

  Color _getCategoryColor(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'conciertos':
        return Colors.purple;
      case 'partidos':
        return Colors.green;
      case 'teatro':
        return Colors.orange;
      case 'festivales':
        return Colors.blue;
      default:
        return AppTheme.primaryColor;
    }
  }
}
