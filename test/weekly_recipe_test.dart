import "package:flutter_test/flutter_test.dart";
import 'package:recipe_suggestion/utils/weekly_recipe.dart';
import 'package:intl/intl.dart';

void main() {
  group("createWeeklyRecipeメソッドの確認", () {
    test('''
      1. カテゴリに7つ以上のデータ登録がある場合、ランダムにデータが並び替えられていることを確認する
      2. カテゴリに7つ未満のデータ登録である場合、重複したデータが配列に格納されていることを確認する
      ''', () {
      WeeklyRecipe weeklyRecipe = WeeklyRecipe();

      List<Map<String, dynamic>> recipeData = _setRecipeDataList();

      /// 上記テストデータからレシピ名のみリストに格納し、
      /// ランダム並び替えされたresultと比較する
      List<String> matchesCategoryIdZero = [];
      List<String> matchesCategoryIdFirst = [];
      List<String> matchesCategoryIdSecond = [];

      recipeData.forEach((recipeNameByCategoryId) {
        if (recipeNameByCategoryId["category"] == 0) {
          matchesCategoryIdZero.add(recipeNameByCategoryId["name"]);
        } else if (recipeNameByCategoryId["category"] == 1) {
          matchesCategoryIdFirst.add(recipeNameByCategoryId["name"]);
        } else {
          matchesCategoryIdSecond.add(recipeNameByCategoryId["name"]);
        }
      });

      Future<Map<int, List<dynamic>>> resultList = weeklyRecipe.createWeeklyRecipe(recipeData);
      resultList.then((value) {
        Map<int, List<dynamic>> recipeNameListByCategoryId = value;

        /// 各カテゴリのレシピ数を確認
        /// 7つ以上登録がある場合は、全てランダム並び替えされており、登録数分の配列長になる
        /// 7つ未満の場合、1週間分のレシピが格納されるため、配列長は7となる
        expect(recipeNameListByCategoryId[0]!.length, 13);
        expect(recipeNameListByCategoryId[1]!.length, 7);
        expect(recipeNameListByCategoryId[2]!.length, 7);

        /// ランダム並び替えした配列とテストデータの並び順が不一致であること
        expect(recipeNameListByCategoryId[0] == matchesCategoryIdZero, isFalse);
        expect(recipeNameListByCategoryId[2] == matchesCategoryIdSecond, isFalse);

        /// カテゴリ内に7つ未満のデータ登録の場合、重複したレシピ名が存在すること
        /// toSetでリスト内に重複している要素を除去している
        expect(recipeNameListByCategoryId[1]!.toSet().toList().length == 7, isFalse);
      });
    });
  });

  group("createWeeklyDateWeekdayメソッドの確認", () {
    test("createWeeklyDateWeekdayメソッドの確認", () {
      /// 現在日付の取得
      DateTime datetime = DateTime.now();
      String formatedDate = "${datetime.year}/${datetime.month}/${datetime.day}";

      WeeklyRecipe weeklyRecipe = WeeklyRecipe();
      Map<String, String> weeklyDate = weeklyRecipe.createWeeklyDateWeekday();

      List<String> list = [];
      List<DateTime> listForDateTime = [];
      weeklyDate.forEach((key, value) {
        list.add(value);
        listForDateTime.add(DateFormat('y/M/d').parse(value));
      });

      print(listForDateTime);

      listForDateTime.forEach((date) {

      });

      for (int i = 1; i <= listForDateTime.length - 1; i++) {
        /// 日付が連番となっていること
        expect(listForDateTime[i - 1].add(const Duration(days: 1)) == listForDateTime[i], isTrue);
      }

      /// 現在日付が存在すること
      expect(list.contains(formatedDate), isTrue);
      /// 1週間分の日付が格納されていること
      expect(weeklyDate.length == 7, isTrue);
    });
  });
}

///
/// レシピデータを以下形式でデータ返却する処理
///   {
///     "name": "XXX", "category": int,
///     ・・・
///   }
///
_setRecipeDataList() {
  return [
    /// カテゴリ:0 13データ
    {"name": "あああ", "category": 0},
    {"name": "うまい主菜", "category": 0},
    {"name": "てすと", "category": 0},
    {"name": "とんかつ", "category": 0},
    {"name": "エビチリ", "category": 0},
    {"name": "カレー", "category": 0},
    {"name": "ハヤシライス", "category": 0},
    {"name": "ハンバーグ", "category": 0},
    {"name": "メンチカツ", "category": 0},
    {"name": "八宝菜", "category": 0},
    {"name": "生姜焼き", "category": 0},
    {"name": "筑前煮", "category": 0},
    {"name": "野菜炒め", "category": 0},
    /// カテゴリ:1 6データ
    {"name": "たこ焼き", "category": 1},
    {"name": "ほうれん草ソテー", "category": 1},
    {"name": "ウィンナー", "category": 1},
    {"name": "ベーコン醤油ソテー", "category": 1},
    {"name": "ポテトフライ", "category": 1},
    {"name": "椎茸蒸し焼き", "category": 1},
    /// カテゴリ:2 7つ
    {"name": "ぜんざい", "category": 2},
    {"name": "アイス", "category": 2},
    {"name": "ショートケーキ", "category": 2},
    {"name": "チョコレートパフェ", "category": 2},
    {"name": "フルール盛り合わせ", "category": 2},
    {"name": "モナカ", "category": 2},
    {"name": "ヨーグルト", "category": 2},
  ];
}