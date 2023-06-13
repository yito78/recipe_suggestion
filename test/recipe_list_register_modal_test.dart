import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'recipe_list_register_modal_test.mocks.dart';
import 'mock.dart';

import 'package:recipe_suggestion/domain/repository/firebase.dart';
import 'package:recipe_suggestion/data/recipe_list_register_modal_data.dart';
import 'package:firebase_core/firebase_core.dart' as firebaseCore;
@GenerateMocks([FirebaseFirestore, Firebase, RecipeListRegisterModalData])
void main() async{
  setupFirebaseAuthMocks();
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await firebaseCore.Firebase.initializeApp();
  });

  test("insertメソッド確認", () async {
    /// モック作成
    var recipeListRegisterModalData = MockRecipeListRegisterModalData();

    recipeListRegisterModalData.insert("主菜", 0);

    verify(recipeListRegisterModalData.insert("主菜", 0)).called(1);
  });
}
