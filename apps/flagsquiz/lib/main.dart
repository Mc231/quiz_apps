import 'package:flutter/material.dart';

import 'app/flags_quiz_app.dart';
import 'initialization/flags_quiz_initializer.dart';

void main() async {
  final dependencies = await FlagsQuizInitializer.initialize();
  runApp(FlagsQuizApp(dependencies: dependencies));
}
