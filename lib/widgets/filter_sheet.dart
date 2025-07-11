import 'package:flutter/material.dart';
import '../constants/texts.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  double radiusValue = 10;
  final TextEditingController keywordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            AppTexts.filterTitle,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Radius:'),
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
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
            ),
            child: const Text(AppTexts.filterApply),
          ),
        ],
      ),
    );
  }
}
