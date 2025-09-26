import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:flutter/material.dart';
import '../entities/ticket.dart';
import 'ticket_card.dart';

class EventTicketsGroup extends StatefulWidget {
  final String eventName;
  final String imageAsset;
  final List<Ticket> tickets;
  final void Function(Ticket) onShowQr;

  const EventTicketsGroup({
    super.key,
    required this.eventName,
    required this.imageAsset,
    required this.tickets,
    required this.onShowQr,
  });

  @override
  State<EventTicketsGroup> createState() => _EventTicketsGroupState();
}

class _EventTicketsGroupState extends State<EventTicketsGroup> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);

    return AnimatedCrossFade(
      crossFadeState: _expanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 250),
      firstChild: _PilePreview(
        eventName: widget.eventName,
        imageAsset: widget.imageAsset,
        count: widget.tickets.length,
        onTap: () => setState(() => _expanded = true),
      ),
      secondChild: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header expanded
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.eventName,
                  style: TextStyle(
                    fontSize: res.dp(2.2),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _expanded = false),
                icon: const Icon(Icons.expand_less),
              ),
            ],
          ),
          SizedBox(height: res.hp(1)),
          ...widget.tickets.map(
            (t) => TicketCard(ticket: t, onShowQr: () => widget.onShowQr(t)),
          ),
          SizedBox(height: res.hp(2)),
        ],
      ),
    );
  }
}

class _PilePreview extends StatelessWidget {
  final String eventName;
  final String imageAsset;
  final int count;
  final VoidCallback onTap;

  const _PilePreview({
    required this.eventName,
    required this.imageAsset,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final int layers = count.clamp(1, 3).toInt();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: res.hp(2)),
        padding: EdgeInsets.all(res.wp(3)),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusNormal),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: res.wp(2),
              offset: Offset(0, res.hp(0.2)),
            ),
          ],
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pila visual de imágenes
            SizedBox(
              height: res.hp(18),
              child: Stack(
                children: [
                  for (int i = 0; i < layers; i++)
                    Positioned(
                      top: (layers - 1 - i) * res.hp(0.8),
                      left: (layers - 1 - i) * res.wp(1.6),
                      right: 0,
                      child: Opacity(
                        opacity: i == layers - 1 ? 1 : 0.85,
                        child: Container(
                          height: res.hp(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusNormal,
                            ),
                            image: DecorationImage(
                              image: AssetImage(imageAsset),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: res.wp(2),
                                offset: Offset(0, res.hp(0.2)),
                              ),
                            ],
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Badge de cantidad
                  Positioned(
                    right: res.wp(2),
                    top: res.hp(0.5),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: res.hp(0.4),
                        horizontal: res.wp(2),
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.highlightBlue,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'x$count',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: res.dp(1.4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: res.hp(1.2)),
            Row(
              children: [
                Expanded(
                  child: Text(
                    eventName,
                    style: TextStyle(
                      fontSize: res.dp(2.0),
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.expand_more,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
