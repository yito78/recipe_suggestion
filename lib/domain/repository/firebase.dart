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
  /// [判定条件について]
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
      // 登録済みデータを取得する
      var weeklyMenu = await _getRegisteredWeeklyMenuByDate(uid);
      var data = _createWeeklyMenuForIsSame(weeklyDateList, weeklyMenu);

      for (var menu in data.entries) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("weekly_menu")
            .doc(menu.key)
            .set(menu.value);
      }
    }

    // 1週間分のメニューを登録する
    for (var date in weeklyDateList) {
      if (uid == null) {
        return;
      }

      var weeklyMenuByDate = await _getWeeklyMenuByDate(uid, date);

      if (weeklyMenuByDate == null) {
        return;
      }

      FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("weekly_menu")
          .doc(date)
          .set(weeklyMenuByDate);
    }
  }

  ///
  /// 1週間メニューデータを1日単位で取得する
  ///
  /// [uid] ログインユーザID
  /// [date] 1週間メニューの内の取得対象日を指定する(文字列型'yyyymmdd')
  ///
  Future<Map<String, dynamic>?> _getWeeklyMenuByDate(
      final String uid, final String date) async {
    final menuByDateRef = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection('weekly_menu')
        .doc(date);

    final menuByDateSnapshot = await menuByDateRef.get();
    final menuByDate = menuByDateSnapshot.data();
    return menuByDate;
  }

  ///
  /// 登録済みの1週間日付を取得する
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
}
