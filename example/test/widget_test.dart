// Basic smoke test for the ExelBid Flutter demo app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:exelbid_plugin_example/main.dart';

void main() {
  testWidgets('Demo app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const ExelbidDemoApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
