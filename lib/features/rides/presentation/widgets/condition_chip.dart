import 'package:flutter/material.dart';

class ConditionChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const ConditionChip({
    super.key,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 0), // Remove internal padding
      labelPadding: const EdgeInsets.only(left: 0, right: 8), // Minimal gap
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
