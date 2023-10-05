import 'package:flutter/material.dart';

import 'helpers.dart';

class ResultScreen extends StatelessWidget {
  final List<String> phones;

  const ResultScreen({super.key, required this.phones});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Results (${phones.length})')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          for (var phone in phones)
            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: PhoneItem(phoneViewText: phone),
            ),
        ],
      ),
    );
  }
}

class PhoneItem extends StatelessWidget {
  const PhoneItem({
    super.key,
    required this.phoneViewText,
  });

  final String phoneViewText;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          phoneViewText,
          style: const TextStyle(color: Colors.black),
        ),
        onTap: () async {
          await Helpers.openPhoneApp(phoneViewText);
        },
      ),
    );
  }
}
