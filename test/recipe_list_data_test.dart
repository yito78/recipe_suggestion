import "package:flutter_test/flutter_test.dart";
import "package:recipe_suggestion/data/recipe_list_data.dart";

void main() {
  test("登録されたレシピ情報が想定通り並び替えられること", () {
    /// sort優先キー : 第一ソートキー category , 第二ソートキー name
    /// nameキーでの並び替えについて
    ///   文字種混合での並び替えは文字コードを利用しているため行われない
    ///   そのため、文字種単位で並び替え処理が行われる
    List<Map<String, dynamic>> recipeList =
    [
      {"name": "たこ焼き", "category": 1},
      {"name": "まめ", "category": 1},
      {"name": "ほうれん草ソテー", "category": 1},
      {"name": "ベーコン醤油ソテー", "category": 1},
      {"name": "ウィンナー", "category": 1},
      {"name": "ポテトフライ", "category": 1},
      {"name": "椎茸蒸し焼き", "category": 1},
      {"name": "寒天", "category": 1},
      {"name": "天ぷら", "category": 1},
      {"name": "てすと", "category": 0},
      {"name": "いためもの", "category": 0},
      {"name": "とんかつ", "category": 0},
      {"name": "カレー", "category": 0},
      {"name": "エビチリ", "category": 0},
      {"name": "ハヤシライス", "category": 0},
      {"name": "八宝菜", "category": 0},
      {"name": "生姜焼き", "category": 0},
      {"name": "筑前煮", "category": 0},
      {"name": "ぜんざい", "category": 2},
      {"name": "おおきいせんべい", "category": 2},
      {"name": "かるめ焼き", "category": 2},
      {"name": "ショートケーキ", "category": 2},
      {"name": "アイス", "category": 2},
      {"name": "チョコレートパフェ", "category": 2}
    ];
    int categoryListLength = 3;

    List<Map<String, dynamic>> result =  [
      {"name": "いためもの", "category": 0},
      {"name": "てすと", "category": 0},
      {"name": "とんかつ", "category": 0},
      {"name": "エビチリ", "category": 0},
      {"name": "カレー", "category": 0},
      {"name": "ハヤシライス", "category": 0},
      {"name": "八宝菜", "category": 0},
      {"name": "生姜焼き", "category": 0},
      {"name": "筑前煮", "category": 0},
      {"name": "たこ焼き", "category": 1},
      {"name": "ほうれん草ソテー", "category": 1},
      {"name": "まめ", "category": 1},
      {"name": "ウィンナー", "category": 1},
      {"name": "ベーコン醤油ソテー", "category": 1},
      {"name": "ポテトフライ", "category": 1},
      {"name": "天ぷら", "category": 1},
      {"name": "寒天", "category": 1},
      {"name": "椎茸蒸し焼き", "category": 1},
      {"name": "おおきいせんべい", "category": 2},
      {"name": "かるめ焼き", "category": 2},
      {"name": "ぜんざい", "category": 2},
      {"name": "アイス", "category": 2},
      {"name": "ショートケーキ", "category": 2},
      {"name": "チョコレートパフェ", "category": 2}
    ];

    final recipeListData = RecipeListData();
    expect(recipeListData.sort(recipeList, categoryListLength), result);
  });

  test("firestoreから取得したデータを[\"レシピ名\", \"カテゴリ名\"]に変換されること", () {
    List<List<String>> recipeCategoryList = [];

    List<Map<String, dynamic>> recipeList = [
      {"name": "たこ焼き", "category": 1},
      {"name": "まめ", "category": 1},
      {"name": "ほうれん草ソテー", "category": 1},
      {"name": "ベーコン醤油ソテー", "category": 1},
      {"name": "ウィンナー", "category": 1},
      {"name": "ポテトフライ", "category": 1},
      {"name": "椎茸蒸し焼き", "category": 1},
      {"name": "寒天", "category": 1},
      {"name": "天ぷら", "category": 1},
      {"name": "てすと", "category": 0},
      {"name": "いためもの", "category": 0},
      {"name": "とんかつ", "category": 0},
      {"name": "カレー", "category": 0},
      {"name": "エビチリ", "category": 0},
      {"name": "ハヤシライス", "category": 0},
      {"name": "八宝菜", "category": 0},
      {"name": "生姜焼き", "category": 0},
      {"name": "筑前煮", "category": 0},
      {"name": "ぜんざい", "category": 2},
      {"name": "おおきいせんべい", "category": 2},
      {"name": "かるめ焼き", "category": 2},
      {"name": "ショートケーキ", "category": 2},
      {"name": "アイス", "category": 2},
      {"name": "チョコレートパフェ", "category": 2}
    ];

    List<Map<String, dynamic>> categoryList = [
      {"category_id": 0, "name": "主菜"},
      {"category_id": 1, "name": "副菜"},
      {"category_id": 2, "name": "デザート"}
    ];

    final recipeListData = RecipeListData();
    
    List<List<String>> result =  [
      ["副菜", "たこ焼き"],
      ["副菜", "まめ"],
      ["副菜", "ほうれん草ソテー"],
      ["副菜", "ベーコン醤油ソテー"],
      ["副菜", "ウィンナー"],
      ["副菜", "ポテトフライ"],
      ["副菜", "椎茸蒸し焼き"],
      ["副菜", "寒天"],
      ["副菜", "天ぷら"],
      ["主菜", "てすと"],
      ["主菜", "いためもの"],
      ["主菜", "とんかつ"],
      ["主菜", "カレー"],
      ["主菜", "エビチリ"],
      ["主菜", "ハヤシライス"],
      ["主菜", "八宝菜"],
      ["主菜", "生姜焼き"],
      ["主菜", "筑前煮"],
      ["デザート", "ぜんざい"],
      ["デザート", "おおきいせんべい"],
      ["デザート", "かるめ焼き"],
      ["デザート", "ショートケーキ"],
      ["デザート", "アイス"],
      ["デザート", "チョコレートパフェ"]
    ];

    expect(
        recipeListData.mergeRecipeNameCategoryName(recipeCategoryList, recipeList, categoryList),
        result
    );
  });
}