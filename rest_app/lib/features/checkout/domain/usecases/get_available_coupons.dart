import 'package:rest_app/features/checkout/domain/entities/promotion_entity.dart';
import 'package:rest_app/features/checkout/domain/repositories/checkout_repository.dart';

class GetAvailableCoupons {
  final CheckoutRepository repository;

  GetAvailableCoupons(this.repository);

  Future<List<PromotionEntity>> call() => repository.getAvailableCoupons();
}
