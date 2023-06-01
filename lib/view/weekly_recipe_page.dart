import 'package:flutter/material.dart';
import 'package:recipe_suggestion/utils/weekly_recipe.dart';

class WeeklyRecipePage extends StatelessWidget {
  const WeeklyRecipePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var setHeight = screenSize.height * 0.22;
    Map<String, String> imagePath = {
      "main": "assets/images/main.png",
      "sub": "assets/images/sub.png",
      "dessert": "assets/images/dessert.png",
    };

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("1週間のレシピ一覧")),
      ),
      body: Table(
        children: [
          TableRow(
            children: [
              _cardWidget("月曜日", setHeight, imagePath),
              _cardWidget("火曜日", setHeight, imagePath),
            ],
          ),
          TableRow(
            children: [
              _cardWidget("水曜日", setHeight, imagePath),
              _cardWidget("木曜日", setHeight, imagePath),
            ],
          ),
          TableRow(
            children: [
              _cardWidget("金曜日", setHeight, imagePath),
              _cardWidget("土曜日", setHeight, imagePath),
            ],
          ),
          TableRow(
            children: [
              _cardWidget("日曜日", setHeight, imagePath),
              _floatActionButton(setHeight),
            ],
          ),
        ],
      ),
    );
  }

  ///
  /// 月曜から日曜までのレシピ表示領域を作成
  ///
  /// weekdayText::画面表示する曜日のテキスト情報
  /// setHeight::表示領域の高さ指定
  ///
  /// 戻り値::月曜から日曜までのレシピ表示領域ウィジェット
  ///
  Widget _cardWidget(weekdayText, setHeight, imagePath) {
    return SizedBox(
        height: setHeight,
        child: Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    weekdayText,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _titleAndRecipeName(imagePath["main"], "主菜レシピ名"),
                    SizedBox(
                      height: 10.0,
                    ),
                    _titleAndRecipeName(imagePath["sub"], "副菜レシピ名"),
                    SizedBox(
                      height: 10.0,
                    ),
                    _titleAndRecipeName(imagePath["dessert"], "デザートレシピ名"),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  ///
  /// カテゴリ名、レシピ名を表示するウィジェット
  ///
  /// imagePath::カテゴリイメージ画像パス
  /// recipe::レシピ名
  ///
  /// 戻り値::各カテゴリタイトル、レシピ名のウィジェット
  ///
  Widget _titleAndRecipeName(imagePath, recipe) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(imagePath, width: 14.0, height: 14.0,)
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(recipe, style: const TextStyle(fontSize: 12.0),),
        ),
      ],
    );
  }

  ///
  /// レシピ一覧の内容更新するボタンを生成
  ///
  /// setHeight::表示領域の高さ指定
  ///
  /// 戻り値::更新ボタンウィジェット
  ///
  Widget _floatActionButton(setHeight) {
    return SizedBox(
      height: setHeight,
      child: Container(
        padding: const EdgeInsets.only(left: 100.0, top: 50.0),
        alignment: Alignment.center,
        child: const FloatingActionButton(
            tooltip: "表示レシピの更新",
            onPressed: null,
            child: Icon(Icons.refresh),
        ),
      ),
    );
  }

  ///
  /// 画面表示用レシピ情報を作成する
  ///
  /// 戻り値::画面表示用レシピ情報
  ///
  Future<Map<int, List<dynamic>>> _createDisplayData() async{
    WeeklyRecipe weeklyRecipe = WeeklyRecipe();
    return await weeklyRecipe.createWeeklyRecipe();
  }
}
