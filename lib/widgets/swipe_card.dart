import 'package:flutter/material.dart';

import '../models/listing.dart';

class SwipeCard extends StatefulWidget {
  final Listing? item;
  final Listing? listing;
  final String? extraInfo;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onChat;
  final VoidCallback? onTap;
  final bool showChatButton;

  const SwipeCard({
    super.key,
    this.item,
    this.listing,
    this.extraInfo,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onChat,
    this.onTap,
    this.showChatButton = false,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> with TickerProviderStateMixin {
  late AnimationController _swipeController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  Offset _dragOffset = Offset.zero;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.15,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onButtonTap(VoidCallback? callback) {
    if (_isAnimating) return;

    _scaleController.forward().then((_) {
      _scaleController.reverse();
      callback?.call();
    });
  }

  void _onSwipeRight() {
    if (_isAnimating) return;
    _isAnimating = true;

    // Sofortige Animation für besseres Feedback
    _swipeController.forward();
    _rotationController.forward();

    // Sofort Callback ausführen für Persistenz
    widget.onSwipeRight?.call();

    Future.delayed(const Duration(milliseconds: 300), () {
      _isAnimating = false;
    });
  }

  void _onSwipeLeft() {
    if (_isAnimating) return;
    _isAnimating = true;

    // Sofortige Animation für besseres Feedback
    _swipeController.forward();
    _rotationController.forward();

    // Sofort Callback ausführen für Persistenz
    widget.onSwipeLeft?.call();

    Future.delayed(const Duration(milliseconds: 300), () {
      _isAnimating = false;
    });
  }

  String? _getTagBasedHint() {
    if (widget.item?.offerTags.isNotEmpty == true &&
        widget.item?.wantTags.isNotEmpty == true) {
      final matchingTags = widget.item!.offerTags
          .where((tag) => widget.item!.wantTags.contains(tag))
          .toList();
      if (matchingTags.isNotEmpty) {
        return 'Gemeinsame Interessen: ${matchingTags.first}';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final itemTitle = widget.item?.title ?? 'Kein Titel';

    return GestureDetector(
      onPanStart: (details) {
        if (_isAnimating) return;
      },
      onPanUpdate: (details) {
        if (_isAnimating) return;
        setState(() {
          _dragOffset += details.delta;
        });
      },
      onPanEnd: (details) {
        if (_isAnimating) return;

        final velocity = details.velocity.pixelsPerSecond;
        final dragDistance = _dragOffset.dx;

        // Swipe-Schwelle (25-35% der Kartenbreite)
        final screenWidth = MediaQuery.of(context).size.width;
        final threshold = screenWidth * 0.3; // 30% der Bildschirmbreite

        if (dragDistance.abs() > threshold || velocity.dx.abs() > 800) {
          if (dragDistance > 0) {
            _onSwipeRight();
          } else {
            _onSwipeLeft();
          }
        } else {
          // Zurück zur Ausgangsposition mit Animation
          _resetCardPosition();
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge(
            [_swipeController, _rotationController, _scaleController]),
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..translate(_dragOffset.dx, _dragOffset.dy)
              ..rotateZ(_dragOffset.dx * 0.02 + _rotationAnimation.value)
              ..scale(_scaleAnimation.value),
            child: Card(
              elevation: 12,
              shadowColor: Colors.black.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: double.infinity,
                height: 420,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Bild (Platzhalter)
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(0, 0, 0, 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.image,
                        size: 70,
                        color: Colors.orangeAccent,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Source Badge (Gruppe/Store)
                    if (widget.item?.sourceBadge != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          widget.item!.sourceBadge!,
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Titel
                    Text(
                      itemTitle,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (widget.extraInfo != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.extraInfo!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    Text(
                      widget.item?.description ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Tag-basierte Hinweise (nur bei Swap)
                    if (widget.item?.category == 'swap' &&
                        (widget.item?.offerTags.isNotEmpty == true ||
                            widget.item?.wantTags.isNotEmpty == true)) ...[
                      if (_getTagBasedHint() != null) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  size: 16, color: Colors.green),
                              const SizedBox(width: 6),
                              Text(
                                _getTagBasedHint()!,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],

                    // Like/Dislike/Chat Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // X-Button (Dislike)
                        AnimatedBuilder(
                          animation: _scaleController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 - _scaleController.value * 0.1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                  onPressed: () =>
                                      _onButtonTap(widget.onSwipeLeft),
                                ),
                              ),
                            );
                          },
                        ),

                        // Chat-Button (immer sichtbar)
                        AnimatedBuilder(
                          animation: _scaleController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 - _scaleController.value * 0.1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.chat_bubble_outline,
                                    color: Colors.blue,
                                    size: 28,
                                  ),
                                  onPressed: () => _onButtonTap(widget.onChat),
                                ),
                              ),
                            );
                          },
                        ),

                        // Herz-Button (Like)
                        AnimatedBuilder(
                          animation: _scaleController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 - _scaleController.value * 0.1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.pink.shade50,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.pink.withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: Colors.pink,
                                    size: 28,
                                  ),
                                  onPressed: () =>
                                      _onButtonTap(widget.onSwipeRight),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _resetCardPosition() {
    _rotationController.reverse();
    setState(() {
      _dragOffset = Offset.zero;
    });
  }
}
