import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else if (await canLaunch('http://$url')) {
    await launch('http://$url');
  } else {
    throw 'Could not launch $url';
  }
}

class LinkTextSpan extends TextSpan {
  LinkTextSpan({TextStyle style, String url, String text})
      : super(
            style: style,
            text: text ?? url,
            recognizer: new TapGestureRecognizer()
              ..onTap = () => _launchURL(url));
}

class RichTextView extends StatelessWidget {
  final String text;

  RichTextView({@required this.text});

  bool _isLink(String input) {
    final matcher = new RegExp(
        r"(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)");
    return matcher.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    final _style = Theme.of(context).textTheme.body2;
    final words = text.split(' ');
    List<TextSpan> span = [];
    words.forEach((word) {
      span.add(_isLink(word)
          ? new LinkTextSpan(
              text: '$word ',
              url: word,
              style: _style.copyWith(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w100))
          : new TextSpan(
              text: '$word ',
              style: _style.copyWith(fontWeight: FontWeight.w100)));
    });
    if (span.length > 0) {
      return new RichText(
        text: new TextSpan(
            text: '',
            children: span,
            style: TextStyle(fontWeight: FontWeight.w100)),
      );
    } else {
      return new Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w100),
      );
    }
  }
}
