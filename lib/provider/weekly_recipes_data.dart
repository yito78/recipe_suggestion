import 'package:recipe_suggestion/domain/repository/firebase_authentication.dart';
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

  // 1週間レシピデータを全件取得
  Future<Map<String, dynamic>> _fetchAllWeeklyRecipesData() async {
    // TODO 以下変数は引数でもらうようにする(現在仮実装)
    List<String> targetDateList = [
      "20231009",
      "20231010",
      "20231011",
      "20231012",
      "20231013",
      "20231014",
      "20231015",
    ];

    final uid = await FirebaseAuthentication.fetchSignedInUserId();

    Map<String, Map<String, dynamic>> weeklyMenuByDate =
        await Firebase.searchAllWeeklyRecipes(uid, targetDateList);

    return weeklyMenuByDate;
  }
}
