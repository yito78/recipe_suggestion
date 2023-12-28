import 'package:intl/intl.dart';
import 'package:recipe_suggestion/domain/repository/firebase_authentication.dart';
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
    String? uid = await FirebaseAuthentication.fetchSignedInUserId();

    DateTime now = DateTime.now();
    DateFormat dateFormat = DateFormat('yyyyMMdd');
    String date = dateFormat.format(now);

    return await updateWeeklyMenu.isNeedCreateWeeklyMenu(date, uid);
  }

  changeIsNeedCreateWeeklyMenu() async {
    Firebase updateWeeklyMenu = Firebase();
    String? uid = await FirebaseAuthentication.fetchSignedInUserId();

    DateTime now = DateTime.now();
    DateFormat dateFormat = DateFormat('yyyyMMdd');
    String date = dateFormat.format(now);

    AsyncValue<bool> stateData = AsyncValue.data(
        await updateWeeklyMenu.isNeedCreateWeeklyMenu(date, uid));

    state = stateData;
  }
}
