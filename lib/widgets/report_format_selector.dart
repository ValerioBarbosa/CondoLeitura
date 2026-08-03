import 'package:flutter/material.dart';

class ReportFormatSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const ReportFormatSelector(
      {super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) => SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'pdf', label: Text('PDF')),
          ButtonSegment(value: 'xlsx', label: Text('Excel')),
          ButtonSegment(value: 'csv', label: Text('CSV')),
        ],
        selected: {selected},
        onSelectionChanged: (v) => onChanged(v.first),
      );
}
