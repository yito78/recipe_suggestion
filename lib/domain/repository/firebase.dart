import 'package:cloud_firestore/cloud_firestore.dart';

// firebase操作に関するクラス
class Firebase {
  //
  // recipesコレクションに登録されたデータを全件取得する
  //
  // 戻り値::recipesコレクションのデータ
  //
  Future<List<Map<String, dynamic>>> searchAllRecipes() async {
    // recipesコレクションのデータ
    List<Map<String, dynamic>> recipesData = [];

    // usersコレクションのデータを取得
    await FirebaseFirestore.instance
        .collection('recipes')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        // firestoreデータを格納できるように型変換
        final data = doc.data() as Map<String, dynamic>;
        // データ格納
        recipesData.add(data);
      });
    }).catchError((e) {
      // TODO アナリティクスにログを出力に差し替える
      print("${e}");
    });

    return recipesData;
  }

  Future<List<Map<String, dynamic>>> searchAllCategories() async{
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

    // final Map<String, dynamic> data2 = {
    //   "name": "天ぷら2",
    //   "category": category,
    // };
    //
    // batch.set(
    //     FirebaseFirestore.instance.collection("index").doc("$category").collection("recipes").doc(name),
    //     data
    // );
    //
    // batch.set(
    //     FirebaseFirestore.instance.collection("recipes").doc("${category}_$name"),
    //     data
    // );
    //
    // await batch.commit().then(
    //         (_) => print("成功")
    // ).catchError(
    //         (e) => print("@@@@@@@@@@@$e")
    // );

    await FirebaseFirestore.instance.runTransaction((transaction) async {

      transaction.set(
          FirebaseFirestore.instance.collection("recipes").doc("${category}_$name"),
          data
      );

      transaction.set(
          FirebaseFirestore.instance.collection("index").doc("$category").collection("recipes").doc(name),
          data
      );
    });
  }
}
