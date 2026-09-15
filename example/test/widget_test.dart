import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:niimbot_print_example/app/data/commons/widgets/main_button_widget.dart';

void main() {
  testWidgets('main button displays its label', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: MainButtonWidget(
            text: 'Print QR Code',
            onPressed: _noOp,
          ),
        ),
      ),
    );

    expect(find.text('Print QR Code'), findsOneWidget);
  });
}

void _noOp() {}
