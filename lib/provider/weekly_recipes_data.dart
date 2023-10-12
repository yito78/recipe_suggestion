import 'package:flutter/cupertino.dart';
import 'package:recipe_suggestion/data/recipe.dart';
import 'package:recipe_suggestion/domain/repository/firebase_authentication.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:recipe_suggestion/domain/repository/firebase.dart';
part 'weekly_recipes_data.g.dart';

@riverpod

/// weekly_recipesデータのNotifierクラス
class WeeklyRecipesDataNotifier extends _$WeeklyRecipesDataNotifier {
  @override
  // 初期化処理
  Future<List<dynamic>?> build() async {
    return await _fetchAllWeeklyRecipesData();
  }

  // 1週間レシピデータを全件取得
  Future<List<dynamic>?> _fetchAllWeeklyRecipesData() async {
    final uid = await FirebaseAuthentication.fetchSignedInUserId();

    List<dynamic>? data = await Firebase.fetchAllWeeklyRecipes(uid);

    // 表示用にデータを加工する
    debugPrint("222222222222222222222222");

    return data;
  }
}
