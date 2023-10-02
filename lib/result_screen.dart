import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultScreen extends StatelessWidget {
  final String text;

  const ResultScreen({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    var phones = _getPhonesFromRowText(text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: ListView(
        children: [
          for (var phoneWithStuff in phones)
            Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PhoneItem(phoneViewText: phoneWithStuff),
                  ],
                )),
        ],
      ),
    );
  }

  List<String> _getPhonesFromRowText(String text) {
    RegExp exp = RegExp(
        r'(\+?\d{1,4}?[-.\s]?\(?\d{1,3}?\)?[-.\s]?\d{1,4}[-.\s]?\d{1,4}[-.\s]?\d{1,9}([-.\s]?\d{1,4})?([-.\s]?\d{1,4})?)');
    Iterable<RegExpMatch> matches = exp.allMatches(text);
    final filteredMatches = matches
        .where(
            (m) => m[0] != null && !m[0]!.contains('\n') && m[0]!.replaceAll(RegExp(r'[()-\s]'), '').length >= 6)
        .map((m) => m[0]!)
        .toList();
    return filteredMatches;
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
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(phoneViewText, style: style),
            const SizedBox(height: 5),
            ElevatedButton.icon(
              onPressed: () async {
                _openPhoneApp(phoneViewText);
              },
              icon: const Icon(Icons.call),
              label: const Text('Call the number'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPhoneApp(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: "tel", path: phoneNumber);
    if (!await launchUrl(phoneUri)) {
      throw Exception('Could not launch $phoneNumber');
    }
  }
}
