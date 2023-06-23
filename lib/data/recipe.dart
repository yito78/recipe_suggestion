import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

/// @freezed
///   データクラスを自動生成するためのアノテーション
///
@freezed
class Recipe with _$Recipe {
  const Recipe._();
  const factory Recipe({
    // @JsonKeyについて
    //   JSONのキーとfreezedのオブジェクトのプロパティーをマッピングする挙動を設定できる
    //   今回は、firestoreからデータ取得した項目名をそのまま利用するため、@JsonKeyは不要
    // @JsonKey(name: 'category') required String category,
    // @JsonKey(name: 'name') required String name,
    required int category,
    required String name,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
}
