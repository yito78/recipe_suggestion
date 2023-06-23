import 'dart:math';

///
/// 1週間レシピ一覧画面に表示するレシピ情報を作成する
///
class WeeklyRecipe {
  ///
  /// 1週間レシピを作成
  ///
  /// recipeData::
  ///
  /// 戻り値::1週間レシピのハッシュ情報
  /// Map<int, dynamic>
  /// {
  ///   0: [ "月曜の主菜レシピ名", "火曜の主菜レシピ名", "水曜の主菜レシピ名", … ],
  ///   1: [ "月曜の副菜レシピ名", "火曜の副菜レシピ名", "水曜の副菜レシピ名", … ],
  ///   2: [ "月曜のデザートレシピ名", "火曜のデザートレシピ名", "水曜のデザートレシピ名", … ],
  /// }
  ///
  Future<Map<int, List<dynamic>>> createWeeklyRecipe(recipeData) async {
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
  /// (1週間分のレシピが存在しない場合)
  /// レシピ情報を月曜から日曜までの情報を作成
  ///
  /// recipeList::カテゴリ分けされたレシピ情報の配列
  ///
  /// 戻り値::1週間レシピの配列情報
  ///   [ "月曜のレシピ名", "火曜のレシピ名", "水曜のレシピ名", … ]
  ///
  List<String> _fetchRandomDataForLessSeven(recipeList) {
    List<String> storingList = ["", "", "", "", "", "", ""];
    int recipeListLength = recipeList.length - 1;
    Random random = Random();

    for (int i = storingList.length - 1; i >= 0; i--) {
      /// 入れ替え要素インデックス
      int swapTargetIndex = random.nextInt(recipeListLength);

      /// 入れ替え先へデータ格納
      storingList[i] = recipeList[swapTargetIndex];
    }

    return storingList;
  }

  ///
  /// レシピデータをカテゴリごとに分類する
  ///
  /// recipeData::Recipeクラスでタイプセーフ化したレシピデータ配列
  ///   [ Recipe(name: "XXX", category: 0), Recipe(name: "YYY", category: 0) ]
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
      if (categorizedData[data.category] == null) {
        categorizedData[data.category] = [data.name];
      } else {
        categorizedData[data.category].add(data.name);
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
  _createDisplayRecipeData(
      Map<int, dynamic> categorizedData, Map<int, List> randomData) {
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

  ///
  /// 1週間分の日付と曜日のハッシュ情報作成処理
  ///
  /// 戻り値::
  ///   {
  ///     "月曜日": "yyyy/mm/dd"
  ///     "火曜日": "yyyy/mm/dd"
  ///     "水曜日": "yyyy/mm/dd"
  ///     "木曜日": "yyyy/mm/dd"
  ///     …
  ///   }
  ///
  Map<String, String> createWeeklyDateWeekday() {
    DateTime datetime = DateTime.now();
    int weekdayInt = datetime.weekday;

    Map<String, String> weeklyDateWeekday = {
      "月曜日": _calclateDate(datetime, 1, weekdayInt),
      "火曜日": _calclateDate(datetime, 2, weekdayInt),
      "水曜日": _calclateDate(datetime, 3, weekdayInt),
      "木曜日": _calclateDate(datetime, 4, weekdayInt),
      "金曜日": _calclateDate(datetime, 5, weekdayInt),
      "土曜日": _calclateDate(datetime, 6, weekdayInt),
      "日曜日": _calclateDate(datetime, 7, weekdayInt),
    };

    return weeklyDateWeekday;
  }

  ///
  /// 基準曜日(アプリ利用日)をもとに該当週の日付を計算する
  /// 計算対象曜日が基準曜日以前である場合、基準曜日の日付から減算する
  /// 逆の場合は、基準曜日の日付に対して加算する
  ///
  ///   例
  ///     基準曜日(アプリ利用日)が水曜日で、計算対象曜日が月曜日の場合の計算について
  ///     水曜日のDateTime.weekday : 3
  ///     月曜日のDateTime.weekday : 1
  ///       3 - 1 = 2
  ///     水曜日のDateTime.nowから2日前として計算する
  ///
  ///     基準曜日(アプリ利用日)が水曜日で、計算対象曜日が木曜日の場合の計算について
  ///     水曜日のDateTime.weekday : 3
  ///     木曜日のDateTime.weekday : 4
  ///       4 - 3 = 1
  ///     水曜日のDateTime.nowから1日後として計算する
  ///
  /// datetime::DateTimeオブジェクト
  /// calcTargetWeekday::計算対象曜日(月曜なら1, 火曜なら2…)
  /// baseWeekday::基準曜日(月曜なら1, 火曜なら2…)
  ///
  String _calclateDate(
      DateTime datetime, int calcTargetWeekday, int baseWeekday) {
    if (baseWeekday >= calcTargetWeekday) {
      DateTime calclatedDate =
          datetime.subtract(Duration(days: baseWeekday - calcTargetWeekday));
      return "${calclatedDate.year}/${calclatedDate.month}/${calclatedDate.day}";
    } else {
      DateTime calclatedDate =
          datetime.add(Duration(days: calcTargetWeekday - baseWeekday));
      return "${calclatedDate.year}/${calclatedDate.month}/${calclatedDate.day}";
    }
  }
}
