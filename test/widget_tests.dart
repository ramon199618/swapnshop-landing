import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swapshop_clean/widgets/cached_image.dart';
import 'package:swapshop_clean/widgets/optimized_list.dart';
import 'package:swapshop_clean/navigation/app_router.dart';
import 'package:swapshop_clean/screens/home_screen.dart';

/// Widget Tests für Kern-Komponenten
void main() {
  group('CachedImage Widget Tests', () {
    testWidgets('CachedImage zeigt Placeholder während des Ladens', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedImage(
              imageUrl: 'https://example.com/image.jpg',
              width: 100,
              height: 100,
            ),
          ),
        ),
      );

      // Prüfen ob Placeholder angezeigt wird
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('CachedImage zeigt Error-Widget bei Fehlern', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedImage(
              imageUrl: 'invalid-url',
              width: 100,
              height: 100,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Prüfen ob Error-Widget angezeigt wird
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('CachedImage mit BorderRadius funktioniert', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedImage(
              imageUrl: 'https://example.com/image.jpg',
              width: 100,
              height: 100,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      );

      // Prüfen ob ClipRRect verwendet wird
      expect(find.byType(ClipRRect), findsOneWidget);
    });
  });

  group('OptimizedList Widget Tests', () {
    testWidgets('OptimizedList zeigt Items korrekt an', (WidgetTester tester) async {
      final testItems = ['Item 1', 'Item 2', 'Item 3'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedList<String>(
              items: testItems,
              itemBuilder: (context, item, index) {
                return ListTile(
                  title: Text(item),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Prüfen ob alle Items angezeigt werden
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('OptimizedList zeigt Loading-Indikator bei hasMore', (WidgetTester tester) async {
      final testItems = ['Item 1', 'Item 2'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedList<String>(
              items: testItems,
              hasMore: true,
              isLoading: true,
              itemBuilder: (context, item, index) {
                return ListTile(
                  title: Text(item),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Prüfen ob Loading-Indikator angezeigt wird
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('OptimizedList ruft onLoadMore auf', (WidgetTester tester) async {
      final testItems = ['Item 1', 'Item 2'];
      bool loadMoreCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedList<String>(
              items: testItems,
              hasMore: true,
              onLoadMore: () {
                loadMoreCalled = true;
              },
              itemBuilder: (context, item, index) {
                return ListTile(
                  title: Text(item),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scrollen um onLoadMore zu triggern
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Prüfen ob onLoadMore aufgerufen wurde
      expect(loadMoreCalled, isTrue);
    });
  });

  group('MemoizedWidget Tests', () {
    testWidgets('MemoizedWidget cached Widget korrekt', (WidgetTester tester) async {
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemoizedWidget(
              dependencies: ['dependency1'],
              builder: () {
                buildCount++;
                return Text('Memoized Widget $buildCount');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Erste Build
      expect(find.text('Memoized Widget 1'), findsOneWidget);
      expect(buildCount, equals(1));

      // Rebuild mit gleichen Dependencies
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemoizedWidget(
              dependencies: ['dependency1'],
              builder: () {
                buildCount++;
                return Text('Memoized Widget $buildCount');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Sollte gecacht sein
      expect(find.text('Memoized Widget 1'), findsOneWidget);
      expect(buildCount, equals(1));

      // Rebuild mit verschiedenen Dependencies
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemoizedWidget(
              dependencies: ['dependency2'],
              builder: () {
                buildCount++;
                return Text('Memoized Widget $buildCount');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Sollte neu gebaut werden
      expect(find.text('Memoized Widget 2'), findsOneWidget);
      expect(buildCount, equals(2));
    });
  });

  group('OptimizedSwipeStack Tests', () {
    testWidgets('OptimizedSwipeStack zeigt Karten korrekt an', (WidgetTester tester) async {
      final testCards = [
        Container(
          height: 200,
          width: 200,
          color: Colors.red,
          child: const Text('Card 1'),
        ),
        Container(
          height: 200,
          width: 200,
          color: Colors.blue,
          child: const Text('Card 2'),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedSwipeStack(
              cards: testCards,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Prüfen ob Karten angezeigt werden
      expect(find.text('Card 1'), findsOneWidget);
      expect(find.text('Card 2'), findsOneWidget);
    });

    testWidgets('OptimizedSwipeStack zeigt Empty-State', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OptimizedSwipeStack(
              cards: [],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Prüfen ob Empty-State angezeigt wird
      expect(find.text('Keine weiteren Artikel verfügbar'), findsOneWidget);
    });
  });

  group('AppRouter Tests', () {
    testWidgets('AppRouter.generateRoute für Home-Route', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.home),
      );

      expect(route, isA<MaterialPageRoute>());
      expect(route.settings.name, equals(AppRouter.home));
    });

    testWidgets('AppRouter.generateRoute für unbekannte Route', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(
        const RouteSettings(name: '/unknown-route'),
      );

      expect(route, isA<MaterialPageRoute>());
    });

    testWidgets('AppRouter Navigation-Helper funktionieren', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: AppRouter.generateRoute,
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AppRouter.pushNamed(context, AppRouter.home);
                },
                child: const Text('Navigate'),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Button drücken
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Prüfen ob Navigation funktioniert
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
