import 'package:flutter/material.dart';
import '../constants/texts.dart';
import '../utils/search_synonyms.dart';

class SearchBar extends StatefulWidget {
  final String? initialQuery;
  final Function(String) onSearch;
  final Function(String)? onSearchChanged;
  final List<String>? suggestions;
  final String hintText;
  final bool showClearButton;

  const SearchBar({
    super.key,
    this.initialQuery,
    required this.onSearch,
    this.onSearchChanged,
    this.suggestions,
    this.hintText = AppTexts.searchHint,
    this.showClearButton = true,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late TextEditingController _controller;
  bool _showSuggestions = false;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _filteredSuggestions = widget.suggestions ?? [];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {
      if (widget.suggestions != null) {
        // Standard-Vorschläge filtern
        final standardSuggestions = widget.suggestions!
            .where(
              (suggestion) =>
                  suggestion.toLowerCase().contains(value.toLowerCase()),
            )
            .toList();

        // Sprachübergreifende Vorschläge hinzufügen
        final crossLanguageSuggestions = SearchSynonyms.getSuggestions(value);

        // Kombiniere und entferne Duplikate
        _filteredSuggestions = <String>{
          ...standardSuggestions,
          ...crossLanguageSuggestions
        }.toList();

        _showSuggestions = value.isNotEmpty && _filteredSuggestions.isNotEmpty;
      }
    });

    // Call onSearchChanged if provided
    widget.onSearchChanged?.call(value);
  }

  void _onSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      widget.onSearch(value.trim());
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  void _onSuggestionTap(String suggestion) {
    _controller.text = suggestion;
    widget.onSearch(suggestion);
    setState(() {
      _showSuggestions = false;
    });
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: widget.showClearButton && _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: _onChanged,
            onSubmitted: _onSubmitted,
            onTap: () {
              if (widget.suggestions != null && _controller.text.isNotEmpty) {
                setState(() {
                  _showSuggestions = _filteredSuggestions.isNotEmpty;
                });
              }
            },
          ),
        ),
        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _filteredSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _filteredSuggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(suggestion),
                  leading: const Icon(
                    Icons.search,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () => _onSuggestionTap(suggestion),
                );
              },
            ),
          ),
      ],
    );
  }
}

// Erweiterte SearchBar mit erweiterten Optionen
class AdvancedSearchBar extends StatefulWidget {
  final String? initialQuery;
  final Function(String, Map<String, dynamic>) onSearch;
  final List<String>? suggestions;
  final Map<String, List<String>>? filters;

  const AdvancedSearchBar({
    super.key,
    this.initialQuery,
    required this.onSearch,
    this.suggestions,
    this.filters,
  });

  @override
  State<AdvancedSearchBar> createState() => _AdvancedSearchBarState();
}

class _AdvancedSearchBarState extends State<AdvancedSearchBar> {
  late TextEditingController _controller;
  final Map<String, dynamic> _selectedFilters = {};

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBar(
          initialQuery: widget.initialQuery,
          onSearch: (query) => widget.onSearch(query, _selectedFilters),
          suggestions: widget.suggestions,
          hintText: 'Artikel suchen...',
        ),
        if (widget.filters != null) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: widget.filters!.entries.map((entry) {
              return FilterChip(
                label: Text(entry.key),
                selected: _selectedFilters.containsKey(entry.key),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedFilters[entry.key] = entry.value.first;
                    } else {
                      _selectedFilters.remove(entry.key);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
