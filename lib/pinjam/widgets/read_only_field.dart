import 'package:flutter/material.dart';

class ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const ReadOnlyField({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          TextField(
            readOnly: true,
            controller: TextEditingController(text: value),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}
