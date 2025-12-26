import 'package:flutter/material.dart';

import 'initialization/flags_quiz_app_provider.dart';

void main() async {
  runApp(await FlagsQuizAppProvider.provideApp());
}
