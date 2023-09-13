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
  Future<List<Recipe>?> build() async {
    return await _fetchAllWeeklyRecipesData();
  }

  // 1週間レシピデータを全件取得
  Future<List<Recipe>?> _fetchAllWeeklyRecipesData() async {
    final uid = await FirebaseAuthentication.fetchSignedInUserId();

    List<Recipe>? data = await Firebase.fetchAllWeeklyRecipes(uid);

    return data;
  }
}
