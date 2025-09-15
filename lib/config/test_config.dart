/// Test-Konfiguration für End-to-End-Tests
class TestConfig {
  // Test-Daten für verschiedene Szenarien
  static const Map<String, dynamic> testUser = {
    'id': 'test_user_123',
    'email': 'test@swapshop.ch',
    'name': 'Test User',
    'isPremium': false,
  };

  static const Map<String, dynamic> testPremiumUser = {
    'id': 'test_premium_user_456',
    'email': 'premium@swapshop.ch',
    'name': 'Premium User',
    'isPremium': true,
    'premiumExpiresAt': '2025-12-31T23:59:59Z',
  };

  static const Map<String, dynamic> testListing = {
    'id': 'test_listing_789',
    'title': 'Test Artikel',
    'description': 'Ein Test-Artikel für End-to-End-Tests',
    'category': 'swap',
    'userId': 'test_user_123',
    'latitude': 47.3769,
    'longitude': 8.5417,
    'location': 'Zürich, Schweiz',
  };

  static const Map<String, dynamic> testStore = {
    'id': 'test_store_101',
    'name': 'Test Store',
    'description': 'Ein Test-Store für End-to-End-Tests',
    'storeType': 'small',
    'ownerId': 'test_user_123',
    'isActive': true,
    'latitude': 47.3769,
    'longitude': 8.5417,
  };

  // Test-Szenarien
  static const List<String> testScenarios = [
    'User Registration & Login',
    'Create Listing (Swap/Sell/Giveaway)',
    'Swipe & Match',
    'Chat & Messaging',
    'Store Creation & Management',
    'Banner Advertisement',
    'Premium Upgrade',
    'Payment Processing',
    'Community Features',
    'Language Switching',
    'Theme Switching',
    'Profile Management',
  ];

  // Test-Daten für verschiedene Kategorien
  static const Map<String, List<String>> testCategories = {
    'swap': ['Elektronik', 'Kleidung', 'Sport', 'Bücher', 'Möbel'],
    'sell': ['Auto', 'Immobilie', 'Antiquitäten', 'Kunst', 'Musikinstrumente'],
    'giveaway': [
      'Kleidung',
      'Bücher',
      'Spielzeug',
      'Haushaltsartikel',
      'Pflanzen'
    ],
  };

  // Test-Locations für geografische Tests
  static const List<Map<String, dynamic>> testLocations = [
    {'name': 'Zürich', 'lat': 47.3769, 'lng': 8.5417, 'country': 'Schweiz'},
    {'name': 'Bern', 'lat': 46.9479, 'lng': 7.4474, 'country': 'Schweiz'},
    {'name': 'Basel', 'lat': 47.5596, 'lng': 7.5886, 'country': 'Schweiz'},
    {'name': 'Genf', 'lat': 46.2044, 'lng': 6.1432, 'country': 'Schweiz'},
    {'name': 'Lausanne', 'lat': 46.5197, 'lng': 6.6323, 'country': 'Schweiz'},
  ];

  // Test-Zahlungsdaten (nur für Tests!)
  static const Map<String, dynamic> testPaymentData = {
    'cardNumber': '4242424242424242', // Stripe Test Card
    'expiryMonth': '12',
    'expiryYear': '2025',
    'cvc': '123',
    'amount': 5.0,
    'currency': 'chf',
  };

  // Test-Community-Daten
  static const Map<String, dynamic> testCommunity = {
    'id': 'test_community_202',
    'name': 'Test Community',
    'description': 'Eine Test-Community für End-to-End-Tests',
    'category': 'Hobby',
    'ownerId': 'test_user_123',
    'memberCount': 5,
    'isPublic': true,
  };

  // Performance-Test-Parameter
  static const Map<String, int> performanceTestParams = {
    'maxListings': 100,
    'maxStores': 20,
    'maxBanners': 10,
    'maxChats': 50,
    'maxMessages': 1000,
  };

  // Error-Test-Szenarien
  static const List<String> errorTestScenarios = [
    'Network Timeout',
    'Invalid Data',
    'Unauthorized Access',
    'Server Error',
    'Storage Full',
    'Invalid Payment',
    'Duplicate Entry',
  ];
}
