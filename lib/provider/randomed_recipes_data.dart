import 'package:recipe_suggestion/data/recipe.dart';
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

    print("444444444444444444444444444444444444444444444444");
    print(await stateData);
    print("444444444444444444444444444444444444444444444444");
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
    Firebase firebase = Firebase();
    List<Recipe>? data = await firebase.searchAllRecipes();
    return data;
  }
}
