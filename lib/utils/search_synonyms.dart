class SearchSynonyms {
  // Sprachübergreifende Synonym-Map für bessere Suche
  static final Map<String, List<String>> synonyms = {
    // Fahrrad / Bike / Bici / Vélo
    'fahrrad': [
      'bike',
      'bici',
      'vélo',
      'velo',
      'velotausch',
      'bicycle',
      'bicicletta'
    ],
    'bike': [
      'fahrrad',
      'bici',
      'vélo',
      'velo',
      'velotausch',
      'bicycle',
      'bicicletta'
    ],
    'bici': [
      'fahrrad',
      'bike',
      'vélo',
      'velo',
      'velotausch',
      'bicycle',
      'bicicletta'
    ],
    'vélo': [
      'fahrrad',
      'bike',
      'bici',
      'velo',
      'velotausch',
      'bicycle',
      'bicicletta'
    ],
    'velotausch': [
      'fahrrad',
      'bike',
      'bici',
      'vélo',
      'velo',
      'bicycle',
      'bicicletta'
    ],

    // Buch / Book / Libro / Livre
    'buch': ['book', 'libro', 'livre', 'bücher', 'books', 'libri', 'livres'],
    'book': ['buch', 'libro', 'livre', 'bücher', 'books', 'libri', 'livres'],
    'libro': ['buch', 'book', 'livre', 'bücher', 'books', 'libri', 'livres'],
    'livre': ['buch', 'book', 'libro', 'bücher', 'books', 'libri', 'livres'],

    // Sport / Sport / Sport / Sport
    'sport': ['sport', 'sport', 'sport', 'sport'],
    'sportausrüstung': [
      'sport equipment',
      'attrezzatura sportiva',
      'équipement sportif'
    ],
    'sport equipment': [
      'sportausrüstung',
      'attrezzatura sportiva',
      'équipement sportif'
    ],
    'attrezzatura sportiva': [
      'sportausrüstung',
      'sport equipment',
      'équipement sportif'
    ],
    'équipement sportif': [
      'sportausrüstung',
      'sport equipment',
      'attrezzatura sportiva'
    ],

    // Haushalt / Household / Casa / Ménage
    'haushalt': [
      'household',
      'casa',
      'ménage',
      'haushaltsartikel',
      'household items',
      'articoli casa',
      'articles ménage'
    ],
    'household': [
      'haushalt',
      'casa',
      'ménage',
      'haushaltsartikel',
      'household items',
      'articoli casa',
      'articles ménage'
    ],
    'casa': [
      'haushalt',
      'household',
      'ménage',
      'haushaltsartikel',
      'household items',
      'articoli casa',
      'articles ménage'
    ],
    'ménage': [
      'haushalt',
      'household',
      'casa',
      'haushaltsartikel',
      'household items',
      'articoli casa',
      'articles ménage'
    ],

    // Musik / Music / Musica / Musique
    'musik': [
      'music',
      'musica',
      'musique',
      'instrument',
      'strumento',
      'instrument'
    ],
    'music': [
      'musik',
      'musica',
      'musique',
      'instrument',
      'strumento',
      'instrument'
    ],
    'musica': [
      'musik',
      'music',
      'musique',
      'instrument',
      'strumento',
      'instrument'
    ],
    'musique': [
      'musik',
      'music',
      'musica',
      'instrument',
      'strumento',
      'instrument'
    ],

    // Technik / Technology / Tecnologia / Technologie
    'technik': [
      'technology',
      'tecnologia',
      'technologie',
      'elektronik',
      'electronics',
      'elettronica',
      'électronique'
    ],
    'technology': [
      'technik',
      'tecnologia',
      'technologie',
      'elektronik',
      'electronics',
      'elettronica',
      'électronique'
    ],
    'tecnologia': [
      'technik',
      'technology',
      'technologie',
      'elektronik',
      'electronics',
      'elettronica',
      'électronique'
    ],
    'technologie': [
      'technik',
      'technology',
      'tecnologia',
      'elektronik',
      'electronics',
      'elettronica',
      'électronique'
    ],

    // Kleidung / Clothing / Abbigliamento / Vêtements
    'kleidung': [
      'clothing',
      'abbigliamento',
      'vêtements',
      'mode',
      'fashion',
      'moda',
      'mode'
    ],
    'clothing': [
      'kleidung',
      'abbigliamento',
      'vêtements',
      'mode',
      'fashion',
      'moda',
      'mode'
    ],
    'abbigliamento': [
      'kleidung',
      'clothing',
      'vêtements',
      'mode',
      'fashion',
      'moda',
      'mode'
    ],
    'vêtements': [
      'kleidung',
      'clothing',
      'abbigliamento',
      'mode',
      'fashion',
      'moda',
      'mode'
    ],

    // Snowboard / Snowboard / Snowboard / Snowboard
    'snowboard': ['snowboard', 'snowboard', 'snowboard', 'snowboard'],
    'ski': ['ski', 'sci', 'ski', 'ski'],
    'sci': ['ski', 'ski', 'ski', 'ski'],

    // Gaming / Gaming / Gaming / Gaming
    'gaming': ['gaming', 'gaming', 'gaming', 'gaming'],
    'spiel': ['game', 'gioco', 'jeu', 'games', 'giochi', 'jeux'],
    'game': ['spiel', 'gioco', 'jeu', 'games', 'giochi', 'jeux'],
    'gioco': ['spiel', 'game', 'jeu', 'games', 'giochi', 'jeux'],
    'jeu': ['spiel', 'game', 'gioco', 'games', 'giochi', 'jeux'],

    // Küche / Kitchen / Cucina / Cuisine
    'küche': [
      'kitchen',
      'cucina',
      'cuisine',
      'küchenartikel',
      'kitchen items',
      'articoli cucina',
      'articles cuisine'
    ],
    'kitchen': [
      'küche',
      'cucina',
      'cuisine',
      'küchenartikel',
      'kitchen items',
      'articoli cucina',
      'articles cuisine'
    ],
    'cucina': [
      'küche',
      'kitchen',
      'cuisine',
      'küchenartikel',
      'kitchen items',
      'articoli cucina',
      'articles cuisine'
    ],
    'cuisine': [
      'küche',
      'kitchen',
      'cucina',
      'küchenartikel',
      'kitchen items',
      'articoli cucina',
      'articles cuisine'
    ],
  };

  // Erweiterte Suche mit Synonymen
  static List<String> getSearchTerms(String query) {
    final normalizedQuery = query.toLowerCase().trim();
    final List<String> searchTerms = [normalizedQuery];

    // Synonyme hinzufügen
    if (synonyms.containsKey(normalizedQuery)) {
      searchTerms.addAll(synonyms[normalizedQuery]!);
    }

    // Teilwörter finden (z.B. "velo" in "velotausch")
    for (final entry in synonyms.entries) {
      if (entry.key.contains(normalizedQuery) ||
          normalizedQuery.contains(entry.key)) {
        searchTerms.addAll(entry.value);
      }
    }

    return searchTerms.toSet().toList(); // Duplikate entfernen
  }

  // Kategorien-Synonyme für bessere Filterung
  static final Map<String, List<String>> categorySynonyms = {
    'velotausch': [
      'bike',
      'bici',
      'vélo',
      'velo',
      'fahrrad',
      'bicycle',
      'bicicletta'
    ],
    'sport': [
      'sport',
      'sport',
      'sport',
      'sport',
      'sportausrüstung',
      'sport equipment',
      'attrezzatura sportiva',
      'équipement sportif'
    ],
    'haushalt': [
      'household',
      'casa',
      'ménage',
      'haushaltsartikel',
      'household items',
      'articoli casa',
      'articles ménage'
    ],
    'bücher': ['books', 'libri', 'livres', 'buch', 'book', 'libro', 'livre'],
    'musik': [
      'music',
      'musica',
      'musique',
      'instrument',
      'strumento',
      'instrument'
    ],
    'technik': [
      'technology',
      'tecnologia',
      'technologie',
      'elektronik',
      'electronics',
      'elettronica',
      'électronique'
    ],
    'kleidung': [
      'clothing',
      'abbigliamento',
      'vêtements',
      'mode',
      'fashion',
      'moda',
      'mode'
    ],
    'wg': [
      'shared apartment',
      'appartamento condiviso',
      'colocation',
      'wohngemeinschaft'
    ],
  };

  // Kategorie-basierte Suche
  static List<String> getCategorySearchTerms(String category) {
    final normalizedCategory = category.toLowerCase().trim();
    final List<String> searchTerms = [normalizedCategory];

    if (categorySynonyms.containsKey(normalizedCategory)) {
      searchTerms.addAll(categorySynonyms[normalizedCategory]!);
    }

    return searchTerms.toSet().toList();
  }

  // Sprachübergreifende Vorschläge generieren
  static List<String> getSuggestions(String partialQuery) {
    final normalizedQuery = partialQuery.toLowerCase().trim();
    final List<String> suggestions = [];

    // Direkte Matches
    for (final entry in synonyms.entries) {
      if (entry.key.startsWith(normalizedQuery)) {
        suggestions.add(entry.key);
        suggestions.addAll(entry.value);
      }
    }

    // Teilwörter in Synonymen
    for (final entry in synonyms.entries) {
      for (final synonym in entry.value) {
        if (synonym.startsWith(normalizedQuery)) {
          suggestions.add(synonym);
          suggestions.add(entry.key);
        }
      }
    }

    return suggestions.toSet().toList(); // Duplikate entfernen
  }
}
