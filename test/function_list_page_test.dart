import "package:firebase_core/firebase_core.dart";
import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import 'package:recipe_suggestion/view/function_list_page.dart';
import 'mock.dart';

void main() async{
  Widget createWidgetForTesting({required Widget child}) {
    return MediaQuery(
        data: const MediaQueryData(),
        child:MaterialApp(home: Scaffold(body: child)));
  }

  testWidgets("機能一覧画面表示確認", (WidgetTester widgetTester) async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();

    await widgetTester.pumpWidget(createWidgetForTesting(child: const ProviderScope(child: FunctionListPage(),)));
    /// 画面表示文字列の確認
    expect(find.text("機能一覧"), findsOneWidget);
  });
}
