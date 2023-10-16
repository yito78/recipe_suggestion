import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:recipe_suggestion/domain/repository/firebase_authentication.dart';

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
  ///
  /// 戻り値::weekly_menuコレクションのデータ
  /// {
  ///   "yyyymmdd": {
  ///     "breakfast": "レシピ名"
  ///     "lunch": "レシピ名"
  ///     "dinner": "レシピ名"
  ///   },
  ///   "yyyymmdd": {
  ///     "breakfast": "レシピ名"
  ///     "lunch": "レシピ名"
  ///     "dinner": "レシピ名"
  ///   },
  /// }
  ///
  static Future<Map<String, Map<String, dynamic>>> searchAllWeeklyRecipes(
      uid, targetDateList) async {
    Map<String, Map<String, dynamic>> weeklyMenuByDate = {};

    for (var date in targetDateList) {
      try {
        final menuByDateRef = FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection('weekly_menu')
            .doc(date);

        final menuByDateSnapshot = await menuByDateRef.get();
        final menuByDate = menuByDateSnapshot.data();
        if (menuByDate != null) {
          // Map多重ネストする場合、ネスト単位で初期化しないとダメ？
          weeklyMenuByDate[date] = {};

          final breakfast = await menuByDate["breakfast"].get();
          weeklyMenuByDate[date]?["breakfast"] = breakfast["name"];

          final lunch = await menuByDate["lunch"].get();
          weeklyMenuByDate[date]?["lunch"] = lunch["name"];

          final dinner = await menuByDate["dinner"].get();
          weeklyMenuByDate[date]?["dinner"] = dinner["name"];
        }
      } catch (e) {
        debugPrint("1週間レシピデータの取得(対象日: $date)に失敗しました : $e");
      }
    }

    return weeklyMenuByDate;
  }
}
