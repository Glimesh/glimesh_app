import 'package:flutter/material.dart';

class SmallChip extends StatelessWidget {
  final Text label;
  final Color? backgroundColor;

  const SmallChip({required this.label, this.backgroundColor}) : super();

  @override
  Widget build(BuildContext context) {
    return Chip(
        label: this.label,
        backgroundColor: this.backgroundColor,
        labelPadding: EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity(vertical: -4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap);
  }
}
