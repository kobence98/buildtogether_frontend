import 'package:flutter/material.dart';

class InnoLoading extends StatelessWidget {
  const InnoLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Image(image: new AssetImage("assets/images/loading_breath.gif")),
      ),
    );
  }
}
