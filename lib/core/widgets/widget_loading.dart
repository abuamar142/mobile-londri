import 'package:flutter/material.dart';

class WidgetLoading extends StatelessWidget {
  final bool usingPadding;

  const WidgetLoading({
    super.key,
    this.usingPadding = false,
  });

  @override
  Widget build(BuildContext context) {
    return usingPadding
        ? const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(),
          );
  }
}
