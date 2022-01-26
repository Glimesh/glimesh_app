import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final String text;

  const Loading(this.text) : super();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Padding(padding: EdgeInsets.all(10)),
          Text(text)
        ],
      ),
    );
  }
}
