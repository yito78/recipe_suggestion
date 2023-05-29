import 'package:flutter/material.dart';

class WeeklyRecipePage extends StatelessWidget {
  const WeeklyRecipePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var setHeight = screenSize.height * 0.22;

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("1週間のレシピ一覧")),
      ),
      body: Table(
        children: [
          TableRow(
            children: [
              _cardWidget("月曜日", setHeight),
              _cardWidget("火曜日", setHeight),
            ],
          ),
          TableRow(
            children: [
              _cardWidget("水曜日", setHeight),
              _cardWidget("木曜日", setHeight),
            ],
          ),
          TableRow(
            children: [
              _cardWidget("金曜日", setHeight),
              _cardWidget("土曜日", setHeight),
            ],
          ),
          TableRow(
            children: [
              _cardWidget("日曜日", setHeight),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  height: setHeight,
                  child: Container(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(child: Icon(Icons.refresh),onPressed: null),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///
  /// 月曜から日曜までのレシピ表示領域を作成
  ///
  /// 戻り値::月曜から日曜までのレシピ表示領域ウィジェット
  ///
  Widget _cardWidget(weekdayText, setHeight) {
    return Container(
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
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        Text("主菜:"),
                        Text("主菜レシピ名"),
                      ],
                    ),
                    SizedBox(
                      height: 3.0,
                    ),
                    Row(
                      children: [
                        Text("副菜:"),
                        Text("副菜レシピ名"),
                      ],
                    ),
                    SizedBox(
                      height: 3.0,
                    ),
                    Row(
                      children: [
                        Text("デザート:"),
                        Text("デザートレシピ名"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
