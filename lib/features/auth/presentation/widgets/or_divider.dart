import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  final String text;
  const OrDivider({super.key, this.text = "Or"});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        
        Expanded(child: Divider(thickness: 1, color: Colors.grey.shade300)),
        Padding(
          
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            text,
            
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
        Expanded(child: Divider(thickness: 1, color: Colors.grey.shade300)),
      ],
    );
  }
}
