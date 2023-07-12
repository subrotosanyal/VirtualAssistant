import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CollapsibleTextWidget extends StatefulWidget {
  final String header;
  final String text;
  final TextEditingController controller;

  const CollapsibleTextWidget({
    required this.header,
    required this.text,
    required this.controller,
  });

  @override
  _CollapsibleTextWidgetState createState() => _CollapsibleTextWidgetState();
}

class _CollapsibleTextWidgetState extends State<CollapsibleTextWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: ListTile(
            title: Text(
              widget.header,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold, // Make the header bold
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.copy),
              onPressed: () {
                copyToClipboard(widget.text);
              },
            ),
          ),
        ),
        if (_isExpanded)
          SingleChildScrollView(
            child: TextFormField(
              controller: widget.controller,
              readOnly: true,
              maxLines: null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
      ],
    );
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text copied to clipboard')),
    );
  }
}
