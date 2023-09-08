import 'package:recipe_suggestion/data/recipe.dart';
import 'package:recipe_suggestion/domain/repository/firebase_authentication.dart';
import 'package:recipe_suggestion/utils/weekly_recipe.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:recipe_suggestion/domain/repository/firebase.dart';
part 'randomed_recipes_data.g.dart';

@riverpod

// Notifierクラス
class RandomedRecipesDataNotifier extends _$RandomedRecipesDataNotifier {
  @override
  // 初期化処理
  Future<Map<int, List<dynamic>>> build() async {
    List<Recipe>? recipeData = await _fetchAllRecipesData();
    WeeklyRecipe weeklyRecipe = WeeklyRecipe();
    Future<Map<int, List<dynamic>>> stateData =
        weeklyRecipe.createWeeklyRecipe(recipeData);

    return stateData;
  }

  // レシピデータ更新処理
  fetchRandomedRecipeDataState() async {
    List<Recipe>? recipeData = await _fetchAllRecipesData();
    WeeklyRecipe weeklyRecipe = WeeklyRecipe();
    AsyncValue<Map<int, List<dynamic>>> stateData =
        AsyncValue.data(await weeklyRecipe.createWeeklyRecipe(recipeData));

    state = stateData;
  }

  // レシピデータを全件取得
  Future<List<Recipe>?> _fetchAllRecipesData() async {
    final uid = await FirebaseAuthentication.fetchSignedInUserId();

    Firebase firebase = Firebase();
    List<Recipe>? data = await firebase.fetchAllRecipes(uid);
    return data;
  }
}
