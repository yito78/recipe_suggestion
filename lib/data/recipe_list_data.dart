class RecipeListData {
  ///
  /// レシピとカテゴリ情報を統合し、配列データとして返却する
  ///
  /// recipeCategoryList::データ格納用配列
  /// recipeList::firestoreから取得したレシピ情報
  /// categoryList::firestoreから取得したカテゴリ情報
  ///
  /// 戻り値::カテゴリ, レシピの2次元配列
  ///
  List<List<String>> mergeRecipeNameCategoryName(
      List<List<String>> recipeCategoryList,
      List<Map<String, dynamic>> recipeList,
      List<Map<String, dynamic>> categoryList) {

    recipeList.forEach((data) {
      String name = data["name"];
      String category = "";

      categoryList.forEach((categoryData) {
        if (categoryData["category_id"] == data["category"]) {
          category = categoryData["name"];
        }
      });
      recipeCategoryList.add([category, name]);
    });

    return recipeCategoryList;
  }

  ///
  /// レシピ一覧情報をソートする
  ///   第一ソートキー : カテゴリID
  ///   第二ソートキー : レシピ名
  /// dartのsortメソッドの仕様上、文字種が混在している場合、文字種内でのみソートを実施
  /// (utf8の文字コードでソートしている)
  ///
  /// recipeList::レシピ情報(1次元配列)
  /// categoryListLength::カテゴリ数
  ///
  List<Map<String, dynamic>> sort(
      List<Map<String, dynamic>> recipeList, categoryListLength) {
    // 第一ソートキー : カテゴリIDでソート
    recipeList.sort((a, b) {
      final sortByCategory = a["category"].compareTo(b["category"]);
      return sortByCategory;
    });

    // 第二ソート処理で使用する変数群
    int loopCount = 0;
    int categoryId = 0;
    bool lastCategoryInitFlg = true;
    List<List<Map<String, dynamic>>> sortedRecipeList = [];
    List<Map<String, dynamic>> tmpList = [];

    // 第二ソートキー : レシピ名でソート
    recipeList.forEach((data) {
      loopCount += 1;

      // カテゴリIDごとにデータを仕分けする
      if ((categoryId + 1) == categoryListLength) {
        // 1つめのデータ専用処理
        if (lastCategoryInitFlg == false) {
          // 初回のみの実行のため、flg切り替え
          lastCategoryInitFlg = true;
          tmpList.sort((a, b) => a["name"].compareTo(b["name"]));
          sortedRecipeList.add(tmpList);
          tmpList = [];
          // 初めのデータをロストさせないための処理
          tmpList.add(data);
        }

        // 2つめ以降のデータ追加処理
        tmpList.add(data);

        // 最後のデータについては、sortedRecipeListデータ格納を実施
        if (recipeList.length == loopCount) {
          tmpList.sort((a, b) => a["name"].compareTo(b["name"]));
          sortedRecipeList.add(tmpList);
        }
      } else if (categoryId == data["category"]) {
        tmpList.add(data);
        // 最後のカテゴリID群用の処理
      } else {
        tmpList.sort((a, b) => a["name"].compareTo(b["name"]));
        sortedRecipeList.add(tmpList);
        tmpList = [];
        // 初めのデータをロストさせないための処理
        tmpList.add(data);
        categoryId += 1;
      }
    });

    // 2次元配列を1次元配列に変換
    List<Map<String, dynamic>> sortedData =
    sortedRecipeList.expand((row) => row).toList();

    return sortedData;
  }
}