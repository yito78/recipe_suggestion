import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:recipe_suggestion/domain/repository/firebase_authentication.dart';
import 'package:recipe_suggestion/utils/weekly_recipe.dart';

import '../../data/recipe.dart';

// firebase操作に関するクラス
class Firebase {
  ///
  /// recipesコレクションに登録されたデータを全件取得する(type safe)
  ///
  /// [uid] ログインユーザID
  ///
  /// 戻り値::recipesコレクションのデータ
  ///
  Future<List<Recipe>?> fetchAllRecipes(uid) async {
    // recipesコレクションのデータ
    final recipeList = <Recipe>[];

    // usersコレクションのデータを取得
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection('recipes')
        .get()
        .then((QuerySnapshot recipesQS) {
      recipesQS.docs.forEach((doc) {
        // firestoreデータを格納できるように型変換
        final data = doc.data() as Map<String, dynamic>;
        // お試し
        recipeList.add(Recipe.fromJson(data));
      });
    }).catchError((e) {
      debugPrint("$e");
    });

    return recipeList;
  }

  ///
  /// recipesコレクションに登録されたデータを全件取得する(type safe)
  ///
  /// [uid] ログインユーザID
  ///
  /// 戻り値::recipesコレクションのデータ
  ///
  Future<Map<int, dynamic>> fetchAllRecipesForRefs(uid) async {
    // recipesコレクションのデータ
    final Map<int, dynamic> recipeByCategoryId = {};

    // usersコレクションのデータを取得
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection('recipes')
        .get()
        .then((QuerySnapshot recipesQS) {
      recipesQS.docs.forEach((doc) {
        // firestoreデータを格納できるように型変換
        final data = doc;
        final id = doc.id;
        final ids = id.split("_");
        final index = int.parse(ids[0]);
        if (recipeByCategoryId[index] == null) {
          recipeByCategoryId[index] = [];
        }
        recipeByCategoryId[index].add(data.reference);
      });
    }).catchError((e) {
      debugPrint("$e");
    });

    return recipeByCategoryId;
  }

  static Future<List<Map<String, dynamic>>> searchAllCategories() async {
    // recipesコレクションのデータ
    List<Map<String, dynamic>> categoriesData = [];

    await FirebaseFirestore.instance
        .collection("categories")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        final data = doc.data() as Map<String, dynamic>;
        categoriesData.add(data);
      });
    }).catchError((e) {
      debugPrint("$e");
    });

    return categoriesData;
  }

  //
  // recipesコレクションに入力データを登録する
  //
  // name::レシピ名
  // category::カテゴリID
  //
  Future insertRecipes(name, category) async {
    final batch = FirebaseFirestore.instance.batch();
    final Map<String, dynamic> data = {
      "name": name,
      "category": category,
    };

    var indexRef = FirebaseFirestore.instance
        .collection("index")
        .doc("$category")
        .collection("recipes")
        .doc(name);
    batch.set(indexRef, data);

    var uid = await _fetchUid();
    var recipesRef = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("recipes")
        .doc("${category}_$name");
    batch.set(recipesRef, data);

    await batch
        .commit()
        .then((_) => debugPrint("データ登録成功!"))
        .catchError((e) => debugPrint("$e"));
  }

  //
  // recipesコレクションに入力データを更新する
  // (delete, insertでデータ入れ替え)
  //
  // name::レシピ名
  // category::カテゴリID
  // originalName::更新前のレシピ名
  // originalCategory::更新前のカテゴリID
  //
  Future updateRecipes(name, category, originalName, originalCategory) async {
    // データ削除
    await deleteRecipes(originalName, originalCategory);
    // データ登録
    await insertRecipes(name, category);
  }

  //
  // recipesコレクションに入力データを削除する
  // (delete, insertでデータ入れ替え)
  //
  // name::レシピ名
  // category::カテゴリID
  //
  Future deleteRecipes(name, category) async {
    final instance = FirebaseFirestore.instance;
    await instance.runTransaction((Transaction tx) async {
      // Firestoreのコレクションを参照
      CollectionReference usersCollection = instance.collection("users");

      var uid = await _fetchUid();
      CollectionReference recipesCollection =
          instance.collection("users").doc(uid).collection("recipes");

      // フィールドの値でクエリを作成
      Query recipesQuery = usersCollection
          .doc(uid)
          .collection("recipes")
          .where("name", isEqualTo: "$name")
          .where("category", isEqualTo: category);

      // クエリを実行してドキュメントを取得
      QuerySnapshot recipesQS = await recipesQuery.get();

      // 取得したドキュメントを処理
      recipesQS.docs.forEach((doc) async {
        // ドキュメントのデータを取得
        try {
          await recipesCollection.doc(doc.id).delete();
          debugPrint("recipes削除成功");
        } catch (e) {
          debugPrint("recipes削除失敗 : $e");
        }
      });

      // Firestoreのコレクションを参照
      CollectionReference indexCollection =
          instance.collection("index").doc("$category").collection("recipes");
      // フィールドの値でクエリを作成
      Query indexQuery = indexCollection
          .where("name", isEqualTo: "$name")
          .where("category", isEqualTo: category);
      // クエリを実行してドキュメントを取得
      QuerySnapshot queryIndexSnapshot = await indexQuery.get();

      // 取得したドキュメントを処理
      queryIndexSnapshot.docs.forEach((doc) async {
        // ドキュメントのデータを取得
        await indexCollection.doc(doc.id).delete().then((value) {
          debugPrint("index削除成功");
        }).catchError((e) {
          debugPrint("index削除失敗 : $e");
        });
      });
    });
  }

  ///
  /// ログインユーザのユーザIDを取得する
  ///
  Future<String?> _fetchUid() async {
    return await FirebaseAuthentication.fetchSignedInUserId();
  }

  ///
  /// 1週間レシピ画面表示用のレシピデータを指定された日付のデータを取得する
  ///
  /// [uid] ログインユーザID
  /// [targetDateList] weekly_menuコレクションから取得する対象の日付リスト
  ///                  リスト内の日付は【yyyymmdd】のフォーマットとする
  ///
  /// 戻り値::weekly_menuコレクションのデータ
  ///   {
  ///     "yyyymmdd": {
  ///       "breakfast": {
  ///         "main": "レシピ名"
  ///         "sub": "レシピ名"
  ///         "dessert": "レシピ名"
  ///       }
  ///       "lunch": {
  ///         "main": "レシピ名"
  ///         "sub": "レシピ名"
  ///         "dessert": "レシピ名"
  ///       }
  ///       "dinner": {
  ///         "main": "レシピ名"
  ///         "sub": "レシピ名"
  ///         "dessert": "レシピ名"
  ///       }
  ///     },
  ///     "yyyymmdd": {
  ///       ・・・
  ///     },
  ///   }
  ///
  static Future<Map<String, Map<String, dynamic>>> searchWeeklyRecipes(
      final String? uid, final List<String> targetDateList) async {
    Map<String, Map<String, dynamic>> weeklyMenuByDate = {};

    // TODO 別issue化する::パス単位のキャッシュを用意する

    for (var date in targetDateList) {
      try {
        final menuByDateRef = FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection('weekly_menu')
            .doc(date);

        final menuByDateSnapshot = await menuByDateRef.get();
        final menuByDate = menuByDateSnapshot.data();
        if (menuByDate == null) continue;
        final menu = <String, dynamic>{
          "breakfast": {"main": "", "sub": "", "dessert": ""},
          "lunch": {"main": "", "sub": "", "dessert": ""},
          "dinner": {"main": "", "sub": "", "dessert": ""},
        };

        final breakfastMain = await menuByDate["breakfast"]["main"].get();
        final breakfastSub = await menuByDate["breakfast"]["sub"].get();
        final breakfastDessert = await menuByDate["breakfast"]["dessert"].get();
        menu["breakfast"]["main"] = breakfastMain["name"];
        menu["breakfast"]["sub"] = breakfastSub["name"];
        menu["breakfast"]["dessert"] = breakfastDessert["name"];

        final lunchMain = await menuByDate["lunch"]["main"].get();
        final lunchSub = await menuByDate["lunch"]["sub"].get();
        final lunchDessert = await menuByDate["lunch"]["dessert"].get();
        menu["lunch"]["main"] = lunchMain["name"];
        menu["lunch"]["sub"] = lunchSub["name"];
        menu["lunch"]["dessert"] = lunchDessert["name"];

        final dinnerMain = await menuByDate["dinner"]["main"].get();
        final dinnerSub = await menuByDate["dinner"]["sub"].get();
        final dinnerDessert = await menuByDate["dinner"]["dessert"].get();
        menu["dinner"]["main"] = dinnerMain["name"];
        menu["dinner"]["sub"] = dinnerSub["name"];
        menu["dinner"]["dessert"] = dinnerDessert["name"];

        weeklyMenuByDate[date] = menu;
      } catch (e) {
        debugPrint("1週間レシピデータの取得(対象日: $date)に失敗しました : $e");
      }
    }

    return weeklyMenuByDate;
  }

  ///
  /// 1週間レシピ一覧画面のデータ更新が必要かについて判定する
  /// 【判定条件について】
  ///   呼び出し元から週初めの日付をもらい、以下ドキュメントを取得する
  ///   user/{user_id}/weekly_menu/yyyymmdd
  ///     取得できない場合 -> メニュー更新必要
  ///     取得できる場合   -> メニュー更新不要
  ///
  ///   週初めのデータがあれば、該当週のデータがあると判断
  ///
  /// [targetDate] 週初めの日付(yyyymmdd)となり、該当ドキュメントに存在するかのチェック用データ
  ///
  /// 戻り値::true  -> メニュー更新必要
  ///        false -> メニュー更新不要
  ///
  Future<bool> isUpdateWeeklyMenu(final String targetDate) async {
    final menuByDateRef = FirebaseFirestore.instance
        .collection("users")
        .doc(await _fetchUid())
        .collection('weekly_menu')
        .doc(targetDate);
    final menuByDateSnapshot = await menuByDateRef.get();
    final menuByDate = menuByDateSnapshot.data();

    if (menuByDate != null) {
      // メニュー更新不要
      return false;
    } else {
      // メニュー更新必要
      return true;
    }
  }

  ///
  /// 1週間メニューデータを今週の日付で再登録する
  /// [isSame]がtrueであれば、現状の1週間メニューデータをそのまま登録し直す
  ///
  /// [uid] ログインユーザID
  ///
  insertWeeklyMenu([bool isSame = false]) async {
    final uid = await FirebaseAuthentication.fetchSignedInUserId();

    // 今週の日付を取得する
    WeeklyRecipe weeklyRecipe = WeeklyRecipe();
    List<String> weeklyDateList = weeklyRecipe.createWeeklyDate();

    if (uid != null && isSame) {
      // 同一データを再登録する処理
      // 登録済みデータを取得する
      Map<String, dynamic>? weeklyMenu =
          await _getRegisteredWeeklyMenuByDate(uid);
      Map<String, dynamic> data =
          _createWeeklyMenuForIsSame(weeklyDateList, weeklyMenu);

      for (var menu in data.entries) {
        try {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .collection("weekly_menu")
              .doc(menu.key)
              .set(menu.value);
        } catch (e) {
          debugPrint("1週間レシピデータの登録に失敗しました : $e");
        }
      }
      return;
    }

    if (uid != null && !isSame) {
      // 登録データを作成する
      Firebase firebase = Firebase();
      Map<int, dynamic> data = await firebase.fetchAllRecipesForRefs(uid);
      WeeklyRecipe weeklyRecipe = WeeklyRecipe();
      Map<int, List<dynamic>> weeklyDataRefs =
          await weeklyRecipe.createWeeklyRecipeForRefs(data);

      // 各レシピデータを取得する
      Map<String, dynamic> weeklyData = await _createWeeklyRecipeDataForRefs(
          uid, weeklyDataRefs, weeklyDateList);

      for (var menu in weeklyData.entries) {
        try {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .collection("weekly_menu")
              .doc(menu.key)
              .set(menu.value);
        } catch (e) {
          debugPrint("1週間レシピデータの登録に失敗しました : $e");
        }
      }

      // TODO 既存データの削除処理を実装する

      return;
    }
  }

  ///
  /// 登録済みの1週間メニューを取得する
  ///
  /// [uid] ログインユーザID
  ///
  Future<Map<String, dynamic>?> _getRegisteredWeeklyMenuByDate(
      final String uid) async {
    final menuByDateRef = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection('weekly_menu')
        .get();

    Map<String, dynamic> registeredWeeklyMenu = {};
    menuByDateRef.docs.forEach((doc) {
      registeredWeeklyMenu[doc.id] = doc.data();
    });

    return registeredWeeklyMenu;
  }

  ///
  /// 既存1週間レシピデータを元にデータ作成する
  ///
  /// [weeklyMenuList] 既存1週間レシピデータのリスト情報
  ///
  /// 戻り値::weekly_menuコレクションのデータ
  ///   {
  ///     [weeklyDateList] : {
  ///       "breakfast": {
  ///         "main": reference
  ///         "sub": reference
  ///         "dessert": reference
  ///       }
  ///       "lunch": {
  ///         "main": reference
  ///         "sub": reference
  ///         "dessert": reference
  ///       }
  ///       "dinner": {
  ///         "main": reference
  ///         "sub": reference
  ///         "dessert": reference
  ///       }
  ///     },
  ///     [weeklyDateList] : {
  ///       ・・・
  ///     },
  ///   }
  ///
  Map<String, dynamic> _createWeeklyMenuForIsSame(
      weeklyDateList, weeklyMenuList) {
    Map<String, dynamic> menu = {};

    // 日付キーを設定するためのカウンタ
    int dateCounter = 0;
    for (var data in weeklyMenuList.entries) {
      menu["${weeklyDateList[dateCounter]}"] = {
        "breakfast": {
          "main": data.value["breakfast"]["main"],
          "sub": data.value["breakfast"]["sub"],
          "dessert": data.value["breakfast"]["dessert"]
        },
        "lunch": {
          "main": data.value["lunch"]["main"],
          "sub": data.value["lunch"]["sub"],
          "dessert": data.value["lunch"]["dessert"]
        },
        "dinner": {
          "main": data.value["dinner"]["main"],
          "sub": data.value["dinner"]["sub"],
          "dessert": data.value["dinner"]["dessert"]
        },
      };

      dateCounter += 1;
    }

    return menu;
  }

  ///
  /// Recipesコレクションの参照型データ[weeklyDataRefs]をweeklyMenuコレクション用の
  /// データ構造に格納する
  ///
  ///   {
  ///     [weeklyDateList] : {
  ///       "breakfast": {
  ///         "main": reference
  ///         "sub": reference
  ///         "dessert": reference
  ///       }
  ///       "lunch": {
  ///         "main": reference
  ///         "sub": reference
  ///         "dessert": reference
  ///       }
  ///       "dinner": {
  ///         "main": reference
  ///         "sub": reference
  ///         "dessert": reference
  ///       }
  ///     },
  ///     [weeklyDateList] : {
  ///       ・・・
  ///     },
  ///   }
  ///
  /// [uid] ログインユーザID
  ///
  Future<Map<String, dynamic>> _createWeeklyRecipeDataForRefs(
      String uid, Map<int, List> weeklyDataRefs, weeklyDateList) async {
    Map<String, dynamic> menu = {};

    // 日付キーを設定するためのカウンタ
    for (int weeklyCounter = 0; weeklyCounter < 7; weeklyCounter++) {
      try {
        menu["${weeklyDateList[weeklyCounter]}"] = {
          "breakfast": {
            "main": weeklyDataRefs[0]?[weeklyCounter],
            "sub": weeklyDataRefs[1]?[weeklyCounter],
            "dessert": weeklyDataRefs[2]?[weeklyCounter]
          },
          "lunch": {
            "main": weeklyDataRefs[0]?[weeklyCounter],
            "sub": weeklyDataRefs[1]?[weeklyCounter],
            "dessert": weeklyDataRefs[2]?[weeklyCounter]
          },
          "dinner": {
            "main": weeklyDataRefs[0]?[weeklyCounter],
            "sub": weeklyDataRefs[1]?[weeklyCounter],
            "dessert": weeklyDataRefs[2]?[weeklyCounter]
          },
        };
      } catch (e) {
        debugPrint("1週間レシピデータの登録に失敗しました : $e");
      }
    }

    return menu;
  }
}
