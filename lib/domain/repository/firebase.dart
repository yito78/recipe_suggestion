import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// firebase操作に関するクラス
class Firebase {
  //
  // recipesコレクションに登録されたデータを全件取得する
  //
  // context::BuildContextオブジェクト
  //
  // 戻り値::recipesコレクションのデータ
  //
  Future<List<Map<String, dynamic>>> searchAllRecipes(context) async {
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
}