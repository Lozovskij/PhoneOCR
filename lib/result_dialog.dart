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
                contentPadding: EdgeInsets.only(left: 17, right: 13),
                title: Text(
                  phone,
                  style: const TextStyle(color: Colors.black),
                ),
                onTap: () async {
                  await Helpers.openPhoneApp(phone);
                },
                trailing: const Icon(
                  Icons.arrow_outward,
                  size: 20,
                ),
              ),
            ),
          SizedBox(
            height: 12,
          ),
          if (phones.length > 0)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  Helpers.makeSureNumbersAreCorrectMessage,
                  style: TextStyle(
                    color: const Color.fromRGBO(38, 50, 56, 1),
                  ),
                ),
              ),
            ),
          if (phones.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'No results found. Please try again',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22),
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
