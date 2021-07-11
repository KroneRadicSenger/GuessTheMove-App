import 'package:flutter/material.dart';

void showSingleChoiceDialog(final BuildContext context, final String title, final List<String> options, final String currentOption, final Function(String) onSelect) => showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: options
                    .map(
                      (option) => RadioListTile(
                        title: Text(option),
                        value: option,
                        groupValue: currentOption,
                        selected: currentOption == option,
                        onChanged: (value) {
                          onSelect(value as String);
                          Navigator.of(context).pop();
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
