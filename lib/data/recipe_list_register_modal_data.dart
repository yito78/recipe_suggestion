import 'package:recipe_suggestion/domain/repository/firebase.dart';

class RecipeListRegisterModalData {
  ///
  /// firebaseにレシピデータ登録する
  ///
  /// registerTargetData::登録データ
  /// beforeUpdateData::更新前レシピ名
  ///
  void insert(recipeName, categoryId) {
    Firebase firebase = Firebase();
    firebase.insertRecipes(recipeName, categoryId);
  }
}
