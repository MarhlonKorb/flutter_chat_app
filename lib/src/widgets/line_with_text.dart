import 'package:flutter/material.dart';

class LineWithText extends StatelessWidget {
  final String text;

  const LineWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(
          child: Divider(
            thickness: 2, 
            color: Colors.grey, 
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            text,
            style: const TextStyle(fontSize: 16.0, color: Colors.grey), 
          ),
        ),
        const Expanded(
          child: Divider(
            thickness: 2,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
