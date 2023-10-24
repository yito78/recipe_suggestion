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
    int recipeListLength = recipeList.length > 1 ? recipeList.length - 1 : 1;
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
  ///   1. 計算対象曜日から基準曜日を減算する
  ///   2. アプリ利用日に1の結果を加算する
  ///
  ///   以下表は、baseWeekdayを2(火曜日)とした場合の日付算出式を一覧にしたものとなる
  ///
  ///   baseWeekday | targetWeekday | 算出式
  ///   ----------------------------------------------------
  ///    2(火曜日)   | 1(月曜日)      | アプリ利用日 + (1(targetWeekday) - 2(baseWeekday))
  ///    2          | 2(火曜日)      | アプリ利用日 + (2(targetWeekday) - 2(baseWeekday))
  ///    2          | 3(水曜日)      | アプリ利用日 + (3(targetWeekday) - 2(baseWeekday))
  ///    2          | 4(木曜日)      | アプリ利用日 + (4(targetWeekday) - 2(baseWeekday))
  ///    2          | 5(金曜日)      | アプリ利用日 + (5(targetWeekday) - 2(baseWeekday))
  ///    2          | 6(土曜日)      | アプリ利用日 + (6(targetWeekday) - 2(baseWeekday))
  ///    2          | 7(日曜日)      | アプリ利用日 + (7(targetWeekday) - 2(baseWeekday))
  ///
  /// [datetime] アプリ利用日となり、曜日情報をもとに各曜日の日付を算出するために利用する
  /// [calcTargetWeekday] 計算対象曜日(月曜なら1, 火曜なら2…)
  /// [baseWeekday] 基準曜日(月曜なら1, 火曜なら2…)
  ///
  String _calclateDate(
      DateTime datetime, int calcTargetWeekday, int baseWeekday) {
    DateTime date =
        datetime.add(Duration(days: calcTargetWeekday - baseWeekday));
    return "${date.year}/${date.month}/${date.day}";
  }

  ///
  /// 1週間分の日付リスト作成処理
  ///
  /// 戻り値::
  ///   ["yyyymmdd", "yyyymmdd", "yyyymmdd", "yyyymmdd", "yyyymmdd", "yyyymmdd", "yyyymmdd"]
  ///
  List<String> createWeeklyDate() {
    DateTime datetime = DateTime.now();
    int weekdayInt = datetime.weekday;

    List<String> weeklyDateList = [
      _calclateDateForList(datetime, 1, weekdayInt),
      _calclateDateForList(datetime, 2, weekdayInt),
      _calclateDateForList(datetime, 3, weekdayInt),
      _calclateDateForList(datetime, 4, weekdayInt),
      _calclateDateForList(datetime, 5, weekdayInt),
      _calclateDateForList(datetime, 6, weekdayInt),
      _calclateDateForList(datetime, 7, weekdayInt),
    ];

    return weeklyDateList;
  }

  ///
  /// 基準曜日(アプリ利用日)をもとに該当週の日付を計算する
  ///   1. 計算対象曜日から基準曜日を減算する
  ///   2. アプリ利用日に1の結果を加算する
  ///
  ///   以下表は、baseWeekdayを2(火曜日)とした場合の日付算出式を一覧にしたものとなる
  ///
  ///   baseWeekday | targetWeekday | 算出式
  ///   ----------------------------------------------------
  ///    2(火曜日)   | 1(月曜日)      | アプリ利用日 + (1(targetWeekday) - 2(baseWeekday))
  ///    2          | 2(火曜日)      | アプリ利用日 + (2(targetWeekday) - 2(baseWeekday))
  ///    2          | 3(水曜日)      | アプリ利用日 + (3(targetWeekday) - 2(baseWeekday))
  ///    2          | 4(木曜日)      | アプリ利用日 + (4(targetWeekday) - 2(baseWeekday))
  ///    2          | 5(金曜日)      | アプリ利用日 + (5(targetWeekday) - 2(baseWeekday))
  ///    2          | 6(土曜日)      | アプリ利用日 + (6(targetWeekday) - 2(baseWeekday))
  ///    2          | 7(日曜日)      | アプリ利用日 + (7(targetWeekday) - 2(baseWeekday))
  ///
  /// [datetime] アプリ利用日となり、曜日情報をもとに各曜日の日付を算出するために利用する
  /// [targetWeekday] 計算対象曜日(月曜なら1, 火曜なら2…)
  /// [baseWeekday] 基準曜日(月曜なら1, 火曜なら2…)
  ///
  /// 戻り値::"yyyymmdd"
  ///
  String _calclateDateForList(
      DateTime datetime, int targetWeekday, int baseWeekday) {
    DateTime date = datetime.add(Duration(days: targetWeekday - baseWeekday));
    return "${date.year}${date.month}${date.day}";
  }
}
