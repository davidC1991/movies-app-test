import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/design_system/design_system.dart';

void main() {
  testWidgets('DebouncedSearchBar espera el debounce antes de notificar',
      (tester) async {
    final received = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: DebouncedSearchBar(
            onChanged: received.add,
            debounce: const Duration(milliseconds: 400),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'bat');

    // Antes de cumplirse el debounce no debe haberse notificado.
    await tester.pump(const Duration(milliseconds: 200));
    expect(received, isEmpty);

    // Tras superar el debounce (total 450ms) se notifica una sola vez.
    await tester.pump(const Duration(milliseconds: 250));
    expect(received, ['bat']);
  });

  testWidgets('DebouncedSearchBar invoca onClear al vaciar el campo',
      (tester) async {
    var cleared = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: DebouncedSearchBar(
            onChanged: (_) {},
            onClear: () => cleared++,
            debounce: const Duration(milliseconds: 400),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'x');
    await tester.enterText(find.byType(TextField), '');

    expect(cleared, greaterThanOrEqualTo(1));
  });
}
