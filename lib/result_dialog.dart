import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phone_ocr/helpers.dart';

class ResultDialog extends StatelessWidget {
  final List<String> phones;

  const ResultDialog({
    super.key,
    required this.phones,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var phone in phones)
            Card(
              child: ListTile(
                title: Text(
                  phone,
                  style: const TextStyle(color: Colors.black),
                ),
                onTap: () async {
                  await Helpers.openPhoneApp(phone);
                },
              ),
            ),
          if (phones.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'No results. Try one more time',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32),
                ),
              ),
            ),
        ],
      ),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
