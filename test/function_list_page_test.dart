import "package:firebase_core/firebase_core.dart";
import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:recipe_suggestion/firebase_options.dart";
import "package:recipe_suggestion/main.dart";
import 'package:mockito/mockito.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:recipe_suggestion/utils/log.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:recipe_suggestion/view/function_list_page.dart';
import 'function_list_page_test.mocks.dart';
import 'mock.dart';

@GenerateMocks([Log, FirebaseAnalytics])
void main() async{
  // setUp(() async{
  //   TestWidgetsFlutterBinding.ensureInitialized();
  //   WidgetsFlutterBinding.ensureInitialized();
  //   setupFirebaseCoreMocks;
  //   // await Firebase.initializeApp(
  //   //   // options: DefaultFirebaseOptions.currentPlatform,
  //   // );
  //   await Firebase.initializeApp();
  // });
  Widget createWidgetForTesting({required Widget child}) {
    return MediaQuery(
        data: const MediaQueryData(),
        child:MaterialApp(home: Scaffold(body: child)));
  }

  testWidgets("機能一覧画面表示確認", (WidgetTester widgetTester) async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();

    var log = MockLog();
    await widgetTester.pumpWidget(createWidgetForTesting(child: const ProviderScope(child: FunctionListPage(),)));
    expect(find.text("機能一覧"), findsOneWidget);
  });
}
