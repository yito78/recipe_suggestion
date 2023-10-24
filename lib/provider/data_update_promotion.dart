import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:recipe_suggestion/domain/repository/firebase.dart';
part 'data_update_promotion.g.dart';

@riverpod

/// 更新促進画面表示判定データのNotifierクラス
class DataUpdatePromotionNotifier extends _$DataUpdatePromotionNotifier {
  @override
  // 初期化処理
  Future<bool> build() async {
    Firebase updateWeeklyMenu = Firebase();
    return await updateWeeklyMenu.isUpdateWeeklyMenu("20231101");
  }
}
