/// Premium-Limits für Swap&Shop
class PremiumLimits {
  /// Maximale Anzahl kostenloser Swaps pro Monat
  static const int maxFreeSwaps = 8;
  
  /// Maximale Anzahl kostenloser Sells pro Monat
  static const int maxFreeSells = 4;
  
  /// Giveaway ist unbegrenzt
  static const int maxFreeGiveaways = -1; // -1 = unbegrenzt
  
  /// Preis für Premium-Monatsabo
  static const double premiumMonthlyPrice = 5.0;
  
  /// Preis für Premium-Jahresabo
  static const double premiumYearlyPrice = 54.0;
  
  /// Preis für Spende (5 zusätzliche Swaps)
  static const double donationPrice = 1.0;
  
  /// Zusätzliche Listings pro Spende
  static const int additionalListingsPerDonation = 5;
  
  /// Premium-Features
  static const List<String> premiumFeatures = [
    'Unbegrenzte Swap-Inserate',
    'Unbegrenzte Sell-Inserate',
    'Eigener Store',
    'Banner-Werbung buchen',
    'Erweiterte Suchfilter',
    'Priorität in Suchergebnissen',
    'Analytics für eigene Inserate',
    'Kundensupport',
  ];
  
  /// Gratis-Features
  static const List<String> freeFeatures = [
    '8 Swap-Inserate pro Monat',
    '4 Sell-Inserate pro Monat',
    'Unbegrenzte Giveaway-Inserate',
    'Grundlegende Suchfunktionen',
    'Chat mit anderen Nutzern',
    'Community-Beitritt',
  ];
}
