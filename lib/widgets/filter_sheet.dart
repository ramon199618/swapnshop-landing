import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/location_service.dart';

class FilterSheet extends StatefulWidget {
  final double? initialRadius;
  final String? initialKeyword;
  final Function(double)? onRadiusChanged;
  final Function(String)? onKeywordChanged;
  final Function(Map<String, dynamic>)? onFilterApplied;

  const FilterSheet({
    super.key,
    this.initialRadius,
    this.initialKeyword,
    this.onRadiusChanged,
    this.onKeywordChanged,
    this.onFilterApplied,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late double radiusValue;
  late final TextEditingController keywordController;

  @override
  void initState() {
    super.initState();
    radiusValue = widget.initialRadius ?? 25.0;
    keywordController =
        TextEditingController(text: widget.initialKeyword ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.filterTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.radius),
              Text('${radiusValue.round()} km'),
            ],
          ),
          Slider(
            value: radiusValue,
            min: 1,
            max: 100,
            divisions: 99,
            label: '${radiusValue.round()}',
            onChanged: (value) => setState(() {
              radiusValue = value;
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: keywordController,
            decoration: const InputDecoration(
              labelText: 'Stichwort',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final location = await LocationService.getCurrentPosition();
              if (!mounted) return;
              widget.onRadiusChanged?.call(radiusValue);
              widget.onKeywordChanged?.call(keywordController.text);
              widget.onFilterApplied?.call({
                'radius': radiusValue,
                'keyword': keywordController.text,
                'latitude': location?.latitude,
                'longitude': location?.longitude,
              });
              if (!mounted) return;
              navigator.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
            ),
            child: Text(l10n.filterApply),
          ),
        ],
      ),
    );
  }
}
