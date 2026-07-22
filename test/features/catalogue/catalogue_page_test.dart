import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:media_tracker/app/theme.dart';
import 'package:media_tracker/features/catalogue/catalogue_page.dart';
import 'package:media_tracker/features/catalogue/widgets/hub_card.dart';

void main() {
  testWidgets('CataloguePage renders two HubCards', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const CataloguePage(),
      ),
    );

    expect(find.byType(HubCard), findsNWidgets(2));
    expect(find.text('Collection'), findsOneWidget);
    expect(find.text('Bucket List'), findsOneWidget);
  });
}
