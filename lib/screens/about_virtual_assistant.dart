import 'package:flutter/material.dart';

class AboutMeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Virtual Assistant'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'The Virtual Assistant is an intelligent application designed to provide various functionalities which offers users a comprehensive and personalized digital assistant experience.\n'),
          Text('Warning: Decompiling or using this code illegally is strictly prohibited. The code is protected by intellectual property rights and should only be used in compliance with the appropriate legal and ethical guidelines.'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
