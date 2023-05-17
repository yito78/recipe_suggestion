import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:recipe_suggestion/domain/repository/firebase.dart';
part 'categories_data.g.dart';

@riverpod

// Notifierクラス
class CategoriesDataNotifier extends _$CategoriesDataNotifier {
  @override
  // 初期化処理
  Future<List<Map<String, dynamic>>> build() async {
    return _fetchAllCategoriesData();
  }

  // カテゴリデータ更新処理
  fetchCategoriesDataState() async{
    state = AsyncValue.data(await _fetchAllCategoriesData());
  }

  // カテゴリデータを全件取得
  Future<List<Map<String, dynamic>>> _fetchAllCategoriesData() async {
    Firebase firebase = Firebase();
    List<Map<String, dynamic>> data = await firebase.searchAllCategories();
    return data;
  }
}
