import 'dart:math';
import 'package:recipe_suggestion/domain/repository/firebase.dart';

///
/// 1週間レシピ一覧画面に表示するレシピ情報を作成する
///
class WeeklyRecipe {
  ///
  /// 1週間レシピを作成
  ///
  /// 戻り値::1週間レシピのハッシュ情報
  /// Map<int, dynamic>
  /// {
  ///   0: [ "月曜の主菜レシピ名", "火曜の主菜レシピ名", "水曜の主菜レシピ名", … ],
  ///   1: [ "月曜の副菜レシピ名", "火曜の副菜レシピ名", "水曜の副菜レシピ名", … ],
  ///   2: [ "月曜のデザートレシピ名", "火曜のデザートレシピ名", "水曜のデザートレシピ名", … ],
  /// }
  ///
  Future<Map<int, List<dynamic>>> createWeeklyRecipe(recipeData) async{
    Firebase firebase = Firebase();

    // レシピ情報取得
    List<Map<String, dynamic>> recipeData = await firebase.searchAllRecipes();

    // レシピ情報をカテゴリごとに分類する
    Map<int, dynamic> categorizedData = _categorizeRecipeData(recipeData);

    // 各カテゴリごとにデータをランダム抽出する
    Map<int, List<dynamic>> randomData = {};
    await _createDisplayRecipeData(categorizedData, randomData);

    return randomData;
  }

  ///
  /// 各カテゴリのレシピ情報を月曜から日曜までの情報を作成
  ///
  /// recipeList::カテゴリ分けされたレシピ情報の配列
  ///
  /// 戻り値::1週間レシピの配列情報
  ///   [ "月曜のレシピ名", "火曜のレシピ名", "水曜のレシピ名", … ]
  ///
  List<dynamic> _fetchRandomData(recipeList) {
    Random random = Random();

    for (int i = recipeList.length - 1; i > 0; i--) {
      /// 入れ替え要素インデックス
      int swapTargetIndex = random.nextInt(i + 1);
      /// 入れ替え先インデックス退避
      String backupData = recipeList[i];
      /// 入れ替え先へデータ格納
      recipeList[i] = recipeList[swapTargetIndex];
      /// 入れ替え元に退避データを格納(データ重複防止)
      recipeList[swapTargetIndex] = backupData;
    }

    return recipeList;
  }

  ///
  /// レシピ情報を月曜から日曜までの情報を作成
  ///
  /// recipeList::カテゴリ分けされたレシピ情報の配列
  ///
  /// 戻り値::1週間レシピの配列情報
  ///   [ "月曜のレシピ名", "火曜のレシピ名", "水曜のレシピ名", … ]
  ///
  List<String> _fetchRandomDataForLessSeven(recipeList) {
    return [ "", "", "", "", "", "", "" ];
  }

  ///
  /// カテゴリIDのリストを作成
  ///
  /// categoryData::firestoreから取得したカテゴリコレクション
  ///
  /// 戻り値::カテゴリIDのリスト
  ///
  List<int> _fetchCategoryId(List<Map<String, dynamic>> categoryData) {
    List<int> categoryList = [];
    categoryData.forEach((data) {
      categoryList.add(data.values.first);
    });

    return categoryList;
  }

  ///
  /// レシピデータをカテゴリごとに分類する
  ///
  /// 戻り値::
  /// Map<int, dynamic>
  /// {
  ///   0(カテゴリID): [ "主菜レシピ名", "主菜レシピ名", "主菜レシピ名", … ],
  ///   1(カテゴリID): [ "副菜レシピ名", "副菜レシピ名", "副菜レシピ名", … ],
  ///   2(カテゴリID): [ "デザートレシピ名", "デザートレシピ名", "デザートレシピ名", … ],
  /// }
  ///
  Map<int, dynamic> _categorizeRecipeData(recipeData) {
    Map<int, dynamic> categorizedData = {};

    recipeData.forEach((data) {
      if (categorizedData[data["category"]] == null) {
        categorizedData[data["category"]] = [data["name"]];
      } else {
        categorizedData[data["category"]].add(data["name"]);
      }
    });

    return categorizedData;
  }

  ///
  /// レシピデータをランダムに並び替える
  ///
  /// categorizedData::firestoreから取得したレシピデータ
  /// randomData::ランダム並び替えした結果を格納する配列
  ///
  /// 戻り値::各カテゴリごとのレシピ名のハッシュ
  ///
  _createDisplayRecipeData(Map<int, dynamic> categorizedData, Map<int, List> randomData) {
    categorizedData.forEach((key, list) {
      if (list.length >= 7) {
        // 1週間分のレシピが存在する場合
        randomData[key] = _fetchRandomData(list);
      } else {
        // 1週間分のレシピが存在しない場合は、同じ要素を使い回す
        randomData[key] = _fetchRandomDataForLessSeven(list);
      }
    });

    return randomData;
  }
}
