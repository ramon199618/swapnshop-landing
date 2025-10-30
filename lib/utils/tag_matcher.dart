import '../utils/search_synonyms.dart';

class TagMatcher {
  /// Prüft, ob die offerTags eines Artikels mit den wantTags eines anderen Artikels übereinstimmen
  static bool hasMatchingTags(List<String> offerTags, List<String> wantTags) {
    if (offerTags.isEmpty || wantTags.isEmpty) return false;

    // Normalisiere alle Tags (kleinbuchstaben, trim)
    final normalizedOfferTags =
        offerTags.map((tag) => tag.toLowerCase().trim()).toSet();
    final normalizedWantTags =
        wantTags.map((tag) => tag.toLowerCase().trim()).toSet();

    // Direkte Übereinstimmung prüfen
    for (final offerTag in normalizedOfferTags) {
      for (final wantTag in normalizedWantTags) {
        if (offerTag == wantTag) return true;

        // Synonym-basierte Übereinstimmung prüfen
        final offerSynonyms = SearchSynonyms.getSearchTerms(offerTag);
        final wantSynonyms = SearchSynonyms.getSearchTerms(wantTag);

        // Prüfe, ob sich die Synonym-Listen überschneiden
        if (offerSynonyms.any((synonym) => wantSynonyms.contains(synonym))) {
          return true;
        }
      }
    }

    return false;
  }

  /// Gibt eine Beschreibung der Übereinstimmung zurück
  static String getMatchDescription(
      List<String> offerTags, List<String> wantTags) {
    if (!hasMatchingTags(offerTags, wantTags)) return '';

    // Finde die übereinstimmenden Tags
    final normalizedOfferTags =
        offerTags.map((tag) => tag.toLowerCase().trim()).toSet();
    final normalizedWantTags =
        wantTags.map((tag) => tag.toLowerCase().trim()).toSet();

    List<String> matches = [];

    for (final offerTag in normalizedOfferTags) {
      for (final wantTag in normalizedWantTags) {
        if (offerTag == wantTag) {
          matches.add(offerTag);
        } else {
          // Synonym-basierte Übereinstimmung
          final offerSynonyms = SearchSynonyms.getSearchTerms(offerTag);
          final wantSynonyms = SearchSynonyms.getSearchTerms(wantTag);

          if (offerSynonyms.any((synonym) => wantSynonyms.contains(synonym))) {
            matches.add('$offerTag ↔ $wantTag');
          }
        }
      }
    }

    if (matches.isEmpty) return '';

    // Erstelle eine benutzerfreundliche Beschreibung
    if (matches.length == 1) {
      return 'Perfekter Tausch möglich: ${matches.first}';
    } else {
      return 'Mehrere Übereinstimmungen: ${matches.take(2).join(', ')}';
    }
  }

  /// Prüft, ob ein perfekter Match vorliegt (gleiche Tags)
  static bool isPerfectMatch(List<String> offerTags, List<String> wantTags) {
    if (offerTags.isEmpty || wantTags.isEmpty) return false;

    final normalizedOfferTags =
        offerTags.map((tag) => tag.toLowerCase().trim()).toSet();
    final normalizedWantTags =
        wantTags.map((tag) => tag.toLowerCase().trim()).toSet();

    // Prüfe, ob mindestens ein Tag exakt übereinstimmt
    return normalizedOfferTags.intersection(normalizedWantTags).isNotEmpty;
  }
}
