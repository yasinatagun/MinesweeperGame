import 'package:flutter/material.dart';

class BombWidget extends StatelessWidget {
  const BombWidget({super.key, required this.revealed, required this.function});
  final bool revealed;
  final VoidCallback? function;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: function,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          color:revealed ? Colors.grey[800] : Colors.grey[400],
          child: revealed ? Center(child: Image.asset("assets/images/bomb.png", height: 20, width: 20, fit: BoxFit.fitHeight,))  : Text(""),
        ),
      ),
    );
  }
}
