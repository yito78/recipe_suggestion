import 'package:recipe_suggestion/data/recipe.dart';
import 'package:recipe_suggestion/domain/repository/firebase_authentication.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:recipe_suggestion/domain/repository/firebase.dart';
part 'recipes_data.g.dart';

@riverpod

// Notifierクラス
class RecipesDataNotifier extends _$RecipesDataNotifier {
  @override
  // 初期化処理
  Future<List<Recipe>?> build() async {
    return await _fetchAllRecipesData();
  }

  // レシピデータ更新処理
  fetchRecipeDataState() async {
    state = AsyncValue.data(await _fetchAllRecipesData());
  }

  // レシピデータを全件取得
  Future<List<Recipe>?> _fetchAllRecipesData() async {
    final uid = await FirebaseAuthentication.fetchSignedInUserId();

    Firebase firebase = Firebase();
    List<Recipe>? data = await firebase.fetchAllRecipes(uid);

    return data;
  }
}
