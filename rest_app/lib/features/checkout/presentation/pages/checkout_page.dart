import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rest_app/features/checkout/domain/entities/payment_details_entity.dart';
import 'package:rest_app/features/checkout/domain/entities/promotion_entity.dart';
import 'package:rest_app/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:rest_app/features/menu/domain/entities/cart_item_entity.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItemEntity> cartItems;

  const CheckoutPage({super.key, required this.cartItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late final CheckoutBloc _checkoutBloc;

  @override
  void initState() {
    super.initState();
    _checkoutBloc = GetIt.instance<CheckoutBloc>();
    _checkoutBloc.add(LoadCheckoutEvent(widget.cartItems));
  }

  @override
  void dispose() {
    _checkoutBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _checkoutBloc,
      child: BlocConsumer<CheckoutBloc, CheckoutState>(
        listener: _onStateChange,
        builder: (context, state) {
          final canGoBack =
              state is! CheckoutLoaded &&
              state is! CheckoutPaymentConfirmed &&
              (state is! CheckoutOrderDetail || !state.isRequestingBill);

          return PopScope(
            canPop: canGoBack,
            child: Scaffold(
              backgroundColor: Colors.grey.shade100,
              appBar: AppBar(
                automaticallyImplyLeading: canGoBack,
                title: const Text(
                  'Confirmar Pedido',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.green.shade700,
                iconTheme: const IconThemeData(color: Colors.white),
                elevation: 0,
              ),
              body: switch (state) {
                CheckoutLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                CheckoutOrderDetail() => _buildOrderDetailContent(state),
                CheckoutLoaded() => _buildContent(state),
                CheckoutPaymentConfirmed() => _buildPaymentSuccessContent(
                  state,
                ),
                CheckoutError() => _buildError(state.message),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          );
        },
      ),
    );
  }

  void _onStateChange(BuildContext context, CheckoutState state) {
    if (state is CheckoutLoaded && state.couponError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.couponError!),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }

    if (state is CheckoutPaymentConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pago confirmado exitosamente.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildContent(CheckoutLoaded state) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderItemsSection(state),
                const SizedBox(height: 20),
                _buildCouponsSection(state),
                const SizedBox(height: 20),
                _buildTipSection(state),
                const SizedBox(height: 20),
                _buildSummarySection(state.orderSummary),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        _buildConfirmButton(state),
      ],
    );
  }

  Widget _buildOrderDetailContent(CheckoutOrderDetail state) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderItemsSection(state),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        _buildRequestBillButton(isLoading: state.isRequestingBill),
      ],
    );
  }

  // ─── Sección: Detalle del pedido ─────────────────────────────────────────

  Widget _buildOrderItemsSection(dynamic state) {
    final cartItems = state is CheckoutLoaded
        ? state.cartItems
        : state is CheckoutOrderDetail
        ? state.cartItems
        : <CartItemEntity>[];

    return _SectionCard(
      title: 'Tu Pedido',
      icon: Icons.receipt_long,
      child: Column(
        children: cartItems.asMap().entries.map((entry) {
          final index = entry.key;
          final cartItem = entry.value;
          final isLast = index == cartItems.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${cartItem.quantity}x',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cartItem.item.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '\$${(cartItem.item.price * cartItem.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ─── Sección: Cupones ─────────────────────────────────────────────────────

  Widget _buildCouponsSection(CheckoutLoaded state) {
    return _SectionCard(
      title: 'Cupones disponibles',
      icon: Icons.local_offer_outlined,
      child: state.isApplyingCoupon
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Actualizando cuenta...'),
                  ],
                ),
              ),
            )
          : state.coupons.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'No hay cupones disponibles',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selecciona un cupón para aplicar un descuento',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: state.coupons.map((coupon) {
                    final isSelected = state.selectedCoupon?.id == coupon.id;
                    return _CouponChip(
                      coupon: coupon,
                      isSelected: isSelected,
                      onTap: () {
                        if (isSelected) {
                          _checkoutBloc.add(const RemoveCouponEvent());
                        } else {
                          _checkoutBloc.add(SelectCouponEvent(coupon));
                        }
                      },
                    );
                  }).toList(),
                ),
                if (state.selectedCoupon != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade700,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '"${state.selectedCoupon!.title}" aplicado',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            _checkoutBloc.add(const RemoveCouponEvent()),
                        child: Text(
                          'Quitar',
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }

  // ─── Sección: Propina ─────────────────────────────────────────────────────

  Widget _buildTipSection(CheckoutLoaded state) {
    const tipOptions = [10, 15, 20];

    return _SectionCard(
      title: 'Propina',
      icon: Icons.volunteer_activism_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Deseas agregar una propina a tu pedido?',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          Text(
            'Esto ayuda a nuestro personal y mejora tu experiencia',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Sin propina
              _TipButton(
                label: 'Sin propina',
                isSelected: state.tipPercentage == 0,
                onTap: () => _checkoutBloc.add(const SelectTipEvent(0)),
              ),
              const SizedBox(width: 8),
              ...tipOptions.map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _TipButton(
                    label: '$tip%',
                    isSelected: state.tipPercentage == tip,
                    onTap: () => _checkoutBloc.add(SelectTipEvent(tip)),
                  ),
                ),
              ),
            ],
          ),
          if (state.orderSummary?.selectedTip != null) ...[
            const SizedBox(height: 10),
            Text(
              'Propina: \$${state.orderSummary?.tipOptions["${state.orderSummary?.selectedTip.replaceAll('%', '')}"]?.tip.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Sección: Resumen de pago ─────────────────────────────────────────────

  Widget _buildSummarySection(PaymentCalculationsEntity? summary) {
    print(
      "Resumen actualizado: Subtotal=${summary?.subtotal}, Descuento=${summary?.discount}",
    );
    return _SectionCard(
      title: 'Resumen de pago',
      icon: Icons.summarize_outlined,
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: summary?.subtotal ?? 0),
          if (summary?.discount != null && summary!.discount > 0)
            _SummaryRow(
              label: 'Descuento',
              value: -summary.discount,
              valueColor: Colors.green.shade700,
            ),
          if (summary?.selectedTip != null)
            _SummaryRow(
              label: 'Propina (${summary?.selectedTip})',
              value:
                  summary
                      ?.tipOptions[summary.selectedTip.replaceAll('%', '')]
                      ?.tip ??
                  0,
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${summary?.total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Botón confirmar pago ─────────────────────────────────────────────────

  Widget _buildConfirmButton(CheckoutLoaded state) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: state.isApplyingCoupon || state.isConfirmingPayment
              ? null
              : () => _checkoutBloc.add(const ConfirmPaymentEvent()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            disabledBackgroundColor: Colors.green.shade200,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: state.isConfirmingPayment
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Confirmar Pago  \$${state.orderSummary?.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildPaymentSuccessContent(CheckoutPaymentConfirmed state) {
    final summary = state.orderSummary;
    final selectedTip = summary?.selectedTip.replaceAll('%', '') ?? '0';
    final selectedTipOption = summary?.tipOptions[selectedTip];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 18),
          Icon(Icons.check_circle, size: 82, color: Colors.green.shade700),
          const SizedBox(height: 16),
          Text(
            'Pago exitoso',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Orden ${state.paymentDetails.id}',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 24),
          _SectionCard(
            title: 'Desglose del pago',
            icon: Icons.receipt_long,
            child: Column(
              children: [
                _SummaryRow(label: 'Subtotal', value: summary?.subtotal ?? 0),
                if ((summary?.discount ?? 0) > 0)
                  _SummaryRow(
                    label: 'Descuento',
                    value: -(summary?.discount ?? 0),
                    valueColor: Colors.green.shade700,
                  ),
                _SummaryRow(
                  label: 'Total sin propina',
                  value: summary?.totalWithoutTip ?? 0,
                ),
                if ((selectedTipOption?.tip ?? 0) > 0)
                  _SummaryRow(
                    label: 'Propina (${summary?.selectedTip})',
                    value: selectedTipOption?.tip ?? 0,
                  ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total pagado',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${(summary?.total ?? state.paymentDetails.total).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Detalle del pedido',
            icon: Icons.restaurant_menu,
            child: Column(
              children: state.cartItems.asMap().entries.map((entry) {
                final item = entry.value;
                final isLast = entry.key == state.cartItems.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.quantity}x ${item.item.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '\$${(item.item.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast) const Divider(height: 1),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.push(
              '/incidents/create',
              extra: state.paymentDetails.id,
            ),
            icon: const Icon(Icons.report_problem_outlined),
            label: const Text('Generar incidencia'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => context.go('/orders'),
            child: const Text('Ver mis órdenes'),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestBillButton({required bool isLoading}) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading
              ? null
              : () => _checkoutBloc.add(const RequestBillEvent()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Solicitar la Cuenta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  // ─── Estado de error ──────────────────────────────────────────────────────

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade700),
            const SizedBox(height: 16),
            const Text(
              'No se pudo cargar el pedido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  _checkoutBloc.add(LoadCheckoutEvent(widget.cartItems)),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets reutilizables ────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _CouponChip extends StatelessWidget {
  final PromotionEntity coupon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CouponChip({
    required this.coupon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final discountLabel =
        '${coupon.discountPercentage.toStringAsFixed(0)}% OFF';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green.shade700 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check_circle, color: Colors.green.shade700, size: 16),
              const SizedBox(width: 6),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.green.shade700
                        : Colors.grey.shade800,
                    fontSize: 13,
                  ),
                ),
                Text(
                  discountLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? Colors.green.shade600
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TipButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade700 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.green.shade700 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value < 0
        ? '-\$${(-value).toStringAsFixed(2)}'
        : '\$${value.toStringAsFixed(2)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
          Text(
            displayValue,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
