abstract class WaiterRepository {
  Future<void> updateToken({required String waiterId, required String token});
  Future<double> getTotalTips();
}
