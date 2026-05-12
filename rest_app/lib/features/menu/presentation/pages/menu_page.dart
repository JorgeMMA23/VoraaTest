import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rest_app/features/menu/domain/entities/cart_item_entity.dart';
import 'package:rest_app/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:rest_app/features/orders/presentation/bloc/orders_bloc.dart';

class MenuPage extends StatefulWidget {
  final String? menuToken;

  const MenuPage({super.key, this.menuToken});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late final MenuBloc _menuBloc;
  late final OrdersBloc _ordersBloc;

  @override
  void initState() {
    super.initState();
    _menuBloc = GetIt.instance<MenuBloc>();
    _menuBloc.add(LoadMenuEvent(menuToken: widget.menuToken ?? ''));
    _ordersBloc = GetIt.instance<OrdersBloc>();
    _ordersBloc.stream.listen((state) {
      if (!mounted) return;
      if (state is OrdersHelpRequested) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La mesera ha sido notificada.')),
        );
      } else if (state is OrdersHelpRequestFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo notificar. Intenta nuevamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _menuBloc.close();
    _ordersBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<MenuBloc, MenuState>(
        bloc: _menuBloc,
        builder: (context, state) {
          return switch (state) {
            MenuLoading() => _buildLoadingState(),
            MenuEmpty() => _buildEmptyState(),
            MenuLoaded() => _buildMenuList(state, state.cartItems),
            MenuError() => _buildErrorState(state.message),
            _ => _buildLoadingState(),
          };
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 72, color: Colors.green.shade700),
            const SizedBox(height: 16),
            const Text(
              'No se encontró ningún platillo en el menú.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'Verifica que tu código QR sea del restaurante correcto e intenta nuevamente.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 72, color: Colors.red.shade700),
            const SizedBox(height: 16),
            const Text(
              'No se pudo cargar el menú',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _menuBloc.add(LoadMenuEvent(menuToken: widget.menuToken ?? ''));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuList(MenuLoaded state, List<CartItemEntity> cartItems) {
    final totalPrice = state.totalPrice;
    final totalItems = state.totalItems;

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.menuItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = state.menuItems[index];
              final cartEntry = state.cartItems.firstWhere(
                (entry) => entry.item.id == item.id,
                orElse: () => CartItemEntity(item: item, quantity: 0),
              );

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.description,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: cartEntry.quantity > 0
                                    ? () {
                                        _menuBloc.add(
                                          RemoveMenuItemFromCartEvent(item),
                                        );
                                      }
                                    : null,
                                icon: const Icon(Icons.remove_circle_outline),
                                color: Colors.green.shade700,
                              ),
                              Text(
                                cartEntry.quantity.toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                onPressed: () {
                                  _menuBloc.add(AddMenuItemToCartEvent(item));
                                },
                                icon: const Icon(Icons.add_circle_outline),
                                color: Colors.green.shade700,
                              ),
                            ],
                          ),
                          Text(
                            cartEntry.quantity > 0
                                ? 'Subtotal: \$${(item.price * cartEntry.quantity).toStringAsFixed(2)}'
                                : 'Agregar al carrito',
                            style: TextStyle(
                              color: cartEntry.quantity > 0
                                  ? Colors.black87
                                  : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Items seleccionados: $totalItems',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '\$${totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _showHelpDialog();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green.shade700,
                        side: BorderSide(color: Colors.green.shade700),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Solicitar ayuda'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: totalItems == 0
                          ? null
                          : () => context.push(
                              '/checkout',
                              extra: state.cartItems,
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Ordenar ahora'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Solicitar ayuda'),
          content: const Text(
            '¿Deseas notificar a la mesera asignada para que te ayude con tu pedido?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _ordersBloc.add(
                  RequestHelpEvent('371a6b53-1415-4bbe-8fe1-a23fa8d4c4cd'),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}
