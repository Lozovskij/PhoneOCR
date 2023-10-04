import 'package:url_launcher/url_launcher.dart';

class Helpers {
  static Future<void> openPhoneApp(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: "tel", path: phoneNumber);
    if (!await launchUrl(phoneUri)) {
      throw Exception('Could not launch $phoneNumber');
    }
  }

  static List<String> getPhonesFromRowText(String text) {
    RegExp exp = RegExp(
        r'(\+?\d{1,4}?[-.\s]?\(?\d{1,3}?\)?[-.\s]?\d{1,4}[-.\s]?\d{1,4}[-.\s]?\d{1,9}([-.\s]?\d{1,4})?([-.\s]?\d{1,4})?)');
    Iterable<RegExpMatch> matches = exp.allMatches(text);
    var filteredMatches = matches
        .where((m) =>
            m[0] != null &&
            !m[0]!.contains('\n') &&
            m[0]!.replaceAll(RegExp(r'[()-\s]'), '').length >= 6)
        .map((m) => m[0]!)
        .toList();

    //at this point first brace can be not recognized as part of a phone number,
    //returning it back
    List<String> result = [];
    for (var phone in filteredMatches) {
      if (phone.contains(')') && !phone.contains('(')) {
        result.add('($phone');
      } else {
        result.add(phone);
      }
    }
    return result;
  }
}
