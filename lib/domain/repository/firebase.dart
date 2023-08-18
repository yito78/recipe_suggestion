import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_suggestion/domain/repository/firebase_authentication.dart';

import '../../data/recipe.dart';

// firebase操作に関するクラス
class Firebase {
  ///
  /// recipesコレクションに登録されたデータを全件取得する(type safe)
  ///
  /// 戻り値::recipesコレクションのデータ
  ///
  Future<List<Recipe>?> searchAllRecipes() async {
    // recipesコレクションのデータ
    final recipeList = <Recipe>[];

    String? uid = await FirebaseAuthentication.fetchSignedInUserId();

    if (uid == null) {
      return null;
    }

    // usersコレクションのデータを取得
    await FirebaseFirestore.instance
        .collection('recipes')
        .where("uid", isEqualTo: uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        // firestoreデータを格納できるように型変換
        final data = doc.data() as Map<String, dynamic>;
        // お試し
        recipeList.add(Recipe.fromJson(data));
      });
    }).catchError((e) {
      // TODO アナリティクスにログを出力に差し替える
      print("${e}");
    });

    return recipeList;
  }

  Future<List<Map<String, dynamic>>> searchAllCategories() async {
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
      print(e);
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

    var recipesRef = FirebaseFirestore.instance
        .collection("recipes")
        .doc("${category}_$name");
    batch.set(recipesRef, data);

    await batch
        .commit()
        .then((_) => print("データ登録成功!"))
        .catchError((e) => print("$e"));
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
  Future updataRecipes(name, category, originalName, originalCategory) async {
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
      CollectionReference recipesCollection = instance.collection("recipes");
      // フィールドの値でクエリを作成
      Query recipesQuery = recipesCollection
          .where("name", isEqualTo: "$name")
          .where("category", isEqualTo: category);
      // クエリを実行してドキュメントを取得
      QuerySnapshot querySnapshot = await recipesQuery.get();
      // 取得したドキュメントを処理
      querySnapshot.docs.forEach((doc) async {
        // ドキュメントのデータを取得
        await recipesCollection.doc("${doc.id}").delete().then((value) {
          print("recipes削除成功");
        }).catchError((e) {
          print("recipes削除失敗 : $e");
        });
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
        await indexCollection.doc("${doc.id}").delete().then((value) {
          print("index削除成功");
        }).catchError((e) {
          print("index削除失敗 : $e");
        });
      });
    });
  }
}
