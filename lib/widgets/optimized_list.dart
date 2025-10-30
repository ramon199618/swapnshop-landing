import 'package:flutter/material.dart';

/// Optimierte Liste mit Lazy Loading und Memoization
class OptimizedList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final ScrollController? scrollController;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final double? itemExtent;
  final Axis scrollDirection;

  const OptimizedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.scrollController,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoading = false,
    this.padding,
    this.itemExtent,
    this.scrollDirection = Axis.vertical,
  });

  @override
  State<OptimizedList<T>> createState() => _OptimizedListState<T>();
}

class _OptimizedListState<T> extends State<OptimizedList<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (widget.hasMore && !widget.isLoading && !_isLoadingMore) {
        setState(() {
          _isLoadingMore = true;
        });
        widget.onLoadMore?.call();
        // Reset loading state after a delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _isLoadingMore = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemExtent: widget.itemExtent,
      scrollDirection: widget.scrollDirection,
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          // Loading indicator at the end
          return Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: widget.isLoading
                ? const CircularProgressIndicator()
                : const SizedBox.shrink(),
          );
        }

        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }
}

/// Memoized Widget für bessere Performance
class MemoizedWidget extends StatefulWidget {
  final Widget Function() builder;
  final List<Object?> dependencies;

  const MemoizedWidget({
    super.key,
    required this.builder,
    required this.dependencies,
  });

  @override
  State<MemoizedWidget> createState() => _MemoizedWidgetState();
}

class _MemoizedWidgetState extends State<MemoizedWidget> {
  Widget? _cachedWidget;
  List<Object?>? _lastDependencies;

  @override
  Widget build(BuildContext context) {
    // Check if dependencies changed
    if (_lastDependencies == null ||
        !_listEquals(_lastDependencies!, widget.dependencies)) {
      _cachedWidget = widget.builder();
      _lastDependencies = List.from(widget.dependencies);
    }

    return _cachedWidget!;
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Optimierter Swipe-Card-Stack mit besserer Performance
class OptimizedSwipeStack extends StatefulWidget {
  final List<Widget> cards;
  final VoidCallback? onStackEmpty;
  final Duration animationDuration;

  const OptimizedSwipeStack({
    super.key,
    required this.cards,
    this.onStackEmpty,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<OptimizedSwipeStack> createState() => _OptimizedSwipeStackState();
}

class _OptimizedSwipeStackState extends State<OptimizedSwipeStack>
    with TickerProviderStateMixin {
  late List<Widget> _visibleCards;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _visibleCards = widget.cards.take(3).toList(); // Nur 3 Karten gleichzeitig laden
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void removeTopCard() {
    if (_visibleCards.isEmpty) return;

    setState(() {
      _visibleCards.removeAt(0);
      
      // Lade nächste Karte wenn weniger als 3 sichtbar sind
      final currentIndex = widget.cards.length - _visibleCards.length;
      if (currentIndex < widget.cards.length) {
        _visibleCards.add(widget.cards[currentIndex]);
      }
    });

    if (_visibleCards.isEmpty) {
      widget.onStackEmpty?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_visibleCards.isEmpty) {
      return const Center(
        child: Text('Keine weiteren Artikel verfügbar'),
      );
    }

    return Stack(
      children: _visibleCards.asMap().entries.map((entry) {
        final index = entry.key;
        final card = entry.value;
        
        return Positioned.fill(
          child: Transform.scale(
            scale: 1.0 - (index * 0.05), // Leichte Verkleinerung für Tiefeneffekt
            child: Transform.translate(
              offset: Offset(0, index * 2.0), // Leichte Verschiebung
              child: Opacity(
                opacity: index == 0 ? 1.0 : 0.8 - (index * 0.1),
                child: card,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
