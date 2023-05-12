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
    }).catchError((e) => print("${e}"));

    return recipesData;
  }
}