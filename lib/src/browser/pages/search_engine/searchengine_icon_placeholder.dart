import 'package:flutter/material.dart';

class SearchEnginePlaceholder extends StatelessWidget {
  final String name;
  final double size;

  const SearchEnginePlaceholder({
    super.key,
    required this.name,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final letter = (name.isNotEmpty ? name[0] : "?").toUpperCase();
    final colors = [
      Colors.blue, Colors.green, Colors.purple, Colors.deepOrange,
      Colors.teal, Colors.red, Colors.indigo, Colors.brown,
    ];

    // pick color based on letter hash → consistent for each name
    final color = colors[name.hashCode.abs() % colors.length];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.52,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
