import 'package:recipe_suggestion/domain/repository/firebase_authentication.dart';
import 'package:recipe_suggestion/utils/weekly_recipe.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:recipe_suggestion/domain/repository/firebase.dart';
part 'weekly_recipes_data.g.dart';

@riverpod

/// weekly_recipesデータのNotifierクラス
class WeeklyRecipesDataNotifier extends _$WeeklyRecipesDataNotifier {
  @override
  // 初期化処理
  Future<Map<String, dynamic>> build() async {
    return await _fetchAllWeeklyRecipesData();
  }

  ///
  /// 1週間レシピデータを取得
  ///
  /// 戻り値::1週間レシピデータ(以下データ構造)
  ///   {
  ///     "yyyymmdd": {
  ///       "breakfast": {
  ///         "main": "レシピ名"
  ///         "sub": "レシピ名"
  ///         "dessert": "レシピ名"
  ///       }
  ///       "lunch": {
  ///         "main": "レシピ名"
  ///         "sub": "レシピ名"
  ///         "dessert": "レシピ名"
  ///       }
  ///       "dinner": {
  ///         "main": "レシピ名"
  ///         "sub": "レシピ名"
  ///         "dessert": "レシピ名"
  ///       }
  ///     },
  ///     "yyyymmdd": {
  ///       ・・・
  ///     },
  ///   }
  ///
  ///
  Future<Map<String, dynamic>> _fetchAllWeeklyRecipesData() async {
    WeeklyRecipe weeklyRecipe = WeeklyRecipe();
    List<String> targetDateList = weeklyRecipe.createWeeklyDate();

    final uid = await FirebaseAuthentication.fetchSignedInUserId();

    Map<String, Map<String, dynamic>> weeklyMenuByDate =
        await Firebase.searchWeeklyRecipes(uid, targetDateList);

    return weeklyMenuByDate;
  }
}
