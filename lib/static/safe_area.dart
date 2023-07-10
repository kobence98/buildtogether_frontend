import 'package:flutter/material.dart';

class InnoSafeArea extends StatelessWidget {
  final Widget child;

  const InnoSafeArea({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: child,
      ),
    );
  }
}