import 'package:url_launcher/url_launcher.dart';

class Helpers {
  static const String makeSureNumbersAreCorrectMessage =
      'Please make sure that the numbers are recognized correctly';

  static Future<void> openPhoneApp(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: "tel", path: phoneNumber);
    if (!await launchUrl(phoneUri)) {
      throw Exception('Could not launch $phoneNumber');
    }
  }

  static List<String> getPhonesFromRowText(String text) {
    RegExp exp = RegExp(
        r'([\)\(]?[+]{0,1}[-.– \)\(]{0,3}\d{1,3}[-.– \)\(]{0,3}\d{1,3}[-.– \)\(]{0,3}\d{1,3}[-.– \)\(]{0,3}\d{1,3}[-.– \)\(]{0,3}\d{1,3}[-.– \)\(]{0,3}\d{1,3})');
    Iterable<RegExpMatch> matches = exp.allMatches(text);
    var filteredMatches = matches
        .where((m) =>
            m[0] != null &&
            !m[0]!.contains('\n') &&
            m[0]!.replaceAll(RegExp(r'[()-\s]'), '').length >= 6)
        .map((m) => m[0]!)
        .toList();

    return filteredMatches;
  }
}
