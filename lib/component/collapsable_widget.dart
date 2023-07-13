import 'package:flutter/material.dart';

class CollapsibleWidget extends StatefulWidget {
  final Widget header;
  final Widget child;

  const CollapsibleWidget({
    required this.header,
    required this.child,
  });

  @override
  _CollapsibleWidgetState createState() => _CollapsibleWidgetState();
}

class _CollapsibleWidgetState extends State<CollapsibleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  void toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: toggleExpanded,
          title: widget.header,
          trailing: RotationTransition(
            turns: _animation,
            child: const Icon(Icons.expand_more),
          ),
        ),
        SizeTransition(
          sizeFactor: _animation,
          child: widget.child,
        ),
      ],
    );
  }
}