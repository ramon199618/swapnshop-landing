import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../constants/colors.dart';

class SwipeCard extends StatefulWidget {
  final Listing? item;
  final String? userName;
  final String? itemTitle;
  final String? matchType; // "Match" oder "Liked"
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onChat;
  final String? extraInfo;
  final bool isSwipeable;

  const SwipeCard({
    super.key,
    this.item,
    this.userName,
    this.itemTitle,
    this.matchType,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onChat,
    this.extraInfo,
    this.isSwipeable = true,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard>
    with SingleTickerProviderStateMixin {
  double _offsetX = 0;
  double _rotation = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.isSwipeable) return;
    setState(() {
      _offsetX += details.delta.dx;
      _rotation = _offsetX / 300;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.isSwipeable) return;
    if (_offsetX > 120 && widget.onSwipeRight != null) {
      _controller.forward(from: 0).then((_) => widget.onSwipeRight!());
    } else if (_offsetX < -120 && widget.onSwipeLeft != null) {
      _controller.forward(from: 0).then((_) => widget.onSwipeLeft!());
    } else {
      setState(() {
        _offsetX = 0;
        _rotation = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMatchCard = !widget.isSwipeable;
    final userName = widget.userName ?? widget.item?.userName ?? '';
    final itemTitle = widget.itemTitle ?? widget.item?.title ?? '';
    final matchType = widget.matchType;
    return GestureDetector(
      onPanUpdate: widget.isSwipeable ? _onPanUpdate : null,
      onPanEnd: widget.isSwipeable ? _onPanEnd : null,
      child: Transform.translate(
        offset: Offset(_offsetX, 0),
        child: Transform.rotate(
          angle: _rotation,
          child: Card(
            elevation: isMatchCard ? 2 : 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isMatchCard ? 12 : 24),
            ),
            color: Colors.white,
            child: Container(
              width: double.infinity,
              height: isMatchCard ? null : 420,
              padding: const EdgeInsets.all(20),
              child: isMatchCard
                  ? ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      leading: CircleAvatar(
                        backgroundColor: matchType == 'Match'
                            ? AppColors.primary
                            : AppColors.accent,
                        child: Icon(
                          matchType == 'Match'
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            itemTitle,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (matchType != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: matchType == 'Match'
                                    ? AppColors.primary
                                    : AppColors.accent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                matchType,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.chat_bubble_outline,
                          color: AppColors.primary,
                        ),
                        onPressed: widget.onChat,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Bild (Platzhalter)
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.image,
                            size: 80,
                            color: Colors.orangeAccent,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Titel
                        Text(
                          itemTitle,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (widget.extraInfo != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.extraInfo!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          widget.item?.subtitle ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // X-Button
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.redAccent,
                                size: 32,
                              ),
                              onPressed: widget.onSwipeLeft,
                            ),
                            // Direkt-Chat-Button
                            IconButton(
                              icon: const Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.blueAccent,
                                size: 32,
                              ),
                              onPressed: widget.onChat,
                            ),
                            // Herz-Button
                            IconButton(
                              icon: const Icon(
                                Icons.favorite,
                                color: Colors.pink,
                                size: 32,
                              ),
                              onPressed: widget.onSwipeRight,
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
