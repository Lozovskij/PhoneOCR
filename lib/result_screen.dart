import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String text;

  const ResultScreen({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    var phones = _getPhonesFromRowText(text);
    print(phones);

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
                    PhoneItem(text: phoneWithStuff),
                  ],
                )
              ),
          ],
        ),
    );
  }

  List<String> _getPhonesFromRowText(String text) {
    RegExp exp = RegExp(r'(\+?\d{1,4}?[-.\s]?\(?\d{1,3}?\)?[-.\s]?\d{1,4}[-.\s]?\d{1,4}[-.\s]?\d{1,9})');
    Iterable<RegExpMatch> matches = exp.allMatches(text);
    final filteredMatches = matches
      .where((m) => m[0] != null && !m[0]!.contains('/n') && m[0]!.length >= 6)
      .map((m) => m[0]!)
      .toList();
    return filteredMatches;
  }
}

class PhoneItem extends StatelessWidget {
  const PhoneItem({
    super.key,
    required this.text,
  });

  final String text;

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
            Text(text, style: style),
            const SizedBox(height: 5),
            ElevatedButton.icon(
              onPressed: () {
                print('pressed');
              },
              icon: Icon(Icons.call),
              label: Text('Call the number'),
            ),
          ],
        )
      ),
    );
  }
}