import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:recipe_suggestion/domain/repository/firebase.dart';
part 'update_promotion_data.g.dart';

@riverpod

/// 更新促進画面表示判定データのNotifierクラス
class UpdatePromotionDataNotifier extends _$UpdatePromotionDataNotifier {
  @override
  // 初期化処理
  Future<bool> build() async {
    Firebase updateWeeklyMenu = Firebase();
    return await updateWeeklyMenu.isUpdateWeeklyMenu("20231101");
  }
}
