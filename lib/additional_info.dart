import 'package:flutter/material.dart';

class extraInfo extends StatelessWidget {
  final Icon icon;
  final Widget text;
  final Widget value;
  const extraInfo({super.key, required this.icon, required this.text, required this.value
  });
  @override
  Widget build(BuildContext context) {
    return
        Column(
          children: [icon, text, value],
        );


  }
}
