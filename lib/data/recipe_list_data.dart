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
    recipeList.sort((a, b) {
      // 第一ソートキー : カテゴリIDでソート
      final aCat = a["category"] as int;
      final bCat = b["category"] as int;

      final catCompResult = aCat.compareTo(bCat);
      if (catCompResult != 0) return catCompResult;

      // 第二ソートキー : レシピ名でソート
      final aName = a["name"] as String;
      final bName = b["name"] as String;

      return aName.compareTo(bName);
    });

    return recipeList;
  }
}
