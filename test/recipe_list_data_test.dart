import "package:flutter_test/flutter_test.dart";
import "package:recipe_suggestion/data/recipe.dart";
import "package:recipe_suggestion/data/recipe_list_data.dart";

void main() {
  test("登録されたレシピ情報が想定通り並び替えられること", () {
    /// sort優先キー : 第一ソートキー category , 第二ソートキー name
    /// nameキーでの並び替えについて
    ///   文字種混合での並び替えは文字コードを利用しているため行われない
    ///   そのため、文字種単位で並び替え処理が行われる
    List<Recipe> recipeList = [
      const Recipe(category: 1, name: "寒天"),
      const Recipe(category: 1, name: "たこ焼き"),
      const Recipe(category: 1, name: "ほうれん草ソテー"),
      const Recipe(category: 1, name: "まめ"),
      const Recipe(category: 1, name: "ウィンナー"),
      const Recipe(category: 1, name: "ベーコン醤油ソテー"),
      const Recipe(category: 1, name: "ポテトフライ"),
      const Recipe(category: 1, name: "椎茸蒸し焼き"),
      const Recipe(category: 1, name: "天ぷら"),
      const Recipe(category: 0, name: "てすと"),
      const Recipe(category: 0, name: "いためもの"),
      const Recipe(category: 0, name: "とんかつ"),
      const Recipe(category: 0, name: "ハヤシライス"),
      const Recipe(category: 0, name: "カレー"),
      const Recipe(category: 0, name: "エビチリ"),
      const Recipe(category: 0, name: "筑前煮"),
      const Recipe(category: 0, name: "生姜焼き"),
      const Recipe(category: 0, name: "八宝菜"),
      const Recipe(category: 2, name: "ぜんざい"),
      const Recipe(category: 2, name: "アイス"),
      const Recipe(category: 2, name: "ショートケーキ"),
      const Recipe(category: 2, name: "チョコレートパフェ"),
      const Recipe(category: 2, name: "かるめ焼き"),
      const Recipe(category: 2, name: "おおきいせんべい"),
    ];
    int categoryListLength = 3;

    List<Recipe> result = [
      const Recipe(category: 0, name: "いためもの"),
      const Recipe(category: 0, name: "てすと"),
      const Recipe(category: 0, name: "とんかつ"),
      const Recipe(category: 0, name: "エビチリ"),
      const Recipe(category: 0, name: "カレー"),
      const Recipe(category: 0, name: "ハヤシライス"),
      const Recipe(category: 0, name: "八宝菜"),
      const Recipe(category: 0, name: "生姜焼き"),
      const Recipe(category: 0, name: "筑前煮"),
      const Recipe(category: 1, name: "たこ焼き"),
      const Recipe(category: 1, name: "ほうれん草ソテー"),
      const Recipe(category: 1, name: "まめ"),
      const Recipe(category: 1, name: "ウィンナー"),
      const Recipe(category: 1, name: "ベーコン醤油ソテー"),
      const Recipe(category: 1, name: "ポテトフライ"),
      const Recipe(category: 1, name: "天ぷら"),
      const Recipe(category: 1, name: "寒天"),
      const Recipe(category: 1, name: "椎茸蒸し焼き"),
      const Recipe(category: 2, name: "おおきいせんべい"),
      const Recipe(category: 2, name: "かるめ焼き"),
      const Recipe(category: 2, name: "ぜんざい"),
      const Recipe(category: 2, name: "アイス"),
      const Recipe(category: 2, name: "ショートケーキ"),
      const Recipe(category: 2, name: "チョコレートパフェ")
    ];

    final recipeListData = RecipeListData();
    expect(recipeListData.sort(recipeList, categoryListLength), result);
  });

  test("firestoreから取得したデータを[\"レシピ名\", \"カテゴリ名\"]に変換されること", () {
    List<List<String>> recipeCategoryList = [];

    List<Recipe> recipeList = [
      const Recipe(category: 0, name: "いためもの"),
      const Recipe(category: 0, name: "てすと"),
      const Recipe(category: 0, name: "とんかつ"),
      const Recipe(category: 0, name: "エビチリ"),
      const Recipe(category: 0, name: "カレー"),
      const Recipe(category: 0, name: "ハヤシライス"),
      const Recipe(category: 0, name: "ハンバーグ"),
      const Recipe(category: 0, name: "メンチカツ"),
      const Recipe(category: 0, name: "生姜焼き"),
      const Recipe(category: 0, name: "筑前煮"),
      const Recipe(category: 0, name: "八宝菜"),
      const Recipe(category: 0, name: "野菜炒め"),
      const Recipe(category: 1, name: "たこ焼き"),
      const Recipe(category: 1, name: "まめ"),
      const Recipe(category: 1, name: "ほうれん草ソテー"),
      const Recipe(category: 1, name: "ウィンナー"),
      const Recipe(category: 1, name: "ベーコン醤油ソテー"),
      const Recipe(category: 1, name: "ポテトフライ"),
      const Recipe(category: 1, name: "寒天"),
      const Recipe(category: 1, name: "椎茸蒸し焼き"),
      const Recipe(category: 1, name: "天ぷら"),
      const Recipe(category: 2, name: "おおきいせんべい"),
      const Recipe(category: 2, name: "かるめ焼き"),
      const Recipe(category: 2, name: "ぜんざい"),
      const Recipe(category: 2, name: "アイス"),
      const Recipe(category: 2, name: "ショートケーキ"),
      const Recipe(category: 2, name: "チョコレートパフェ"),
    ];

    List<Map<String, dynamic>> categoryList = [
      {"category_id": 0, "name": "主菜"},
      {"category_id": 1, "name": "副菜"},
      {"category_id": 2, "name": "デザート"}
    ];

    final recipeListData = RecipeListData();

    List<List<String>> result = [
      ["主菜", "いためもの"],
      ["主菜", "てすと"],
      ["主菜", "とんかつ"],
      ["主菜", "エビチリ"],
      ["主菜", "カレー"],
      ["主菜", "ハヤシライス"],
      ["主菜", "ハンバーグ"],
      ["主菜", "メンチカツ"],
      ["主菜", "生姜焼き"],
      ["主菜", "筑前煮"],
      ["主菜", "八宝菜"],
      ["主菜", "野菜炒め"],
      ["副菜", "たこ焼き"],
      ["副菜", "まめ"],
      ["副菜", "ほうれん草ソテー"],
      ["副菜", "ウィンナー"],
      ["副菜", "ベーコン醤油ソテー"],
      ["副菜", "ポテトフライ"],
      ["副菜", "寒天"],
      ["副菜", "椎茸蒸し焼き"],
      ["副菜", "天ぷら"],
      ["デザート", "おおきいせんべい"],
      ["デザート", "かるめ焼き"],
      ["デザート", "ぜんざい"],
      ["デザート", "アイス"],
      ["デザート", "ショートケーキ"],
      ["デザート", "チョコレートパフェ"]
    ];

    expect(
        recipeListData.mergeRecipeNameCategoryName(
            recipeCategoryList, recipeList, categoryList),
        result);
  });
}
