import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void showAlertDialog(final BuildContext context, final String title, final String message, {final String confirmText = 'OK'}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          child: Text(confirmText),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}
