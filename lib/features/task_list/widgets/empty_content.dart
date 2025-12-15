import 'package:flutter/material.dart';

class EmptyContent extends StatelessWidget {
  const EmptyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sentiment_satisfied_alt, size: 64),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
