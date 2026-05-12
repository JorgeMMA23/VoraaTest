import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rest_app/core/di/injection.dart';
import 'package:rest_app/core/push/push_notification_service.dart';
import 'package:rest_app/features/waiter/presentation/bloc/waiter_bloc.dart';

class WaiterDashboardPage extends StatefulWidget {
  const WaiterDashboardPage({super.key});

  @override
  State<WaiterDashboardPage> createState() => _WaiterDashboardPageState();
}

class _WaiterDashboardPageState extends State<WaiterDashboardPage> {
  late final StreamSubscription<RemoteMessage> _pushSubscription;
  late final WaiterBloc _waiterBloc;
  double _tipsTotal = 0;
  final List<_TableHelpAlert> _helpAlerts = [];

  @override
  void initState() {
    super.initState();
    _waiterBloc = getIt<WaiterBloc>();
    _waiterBloc.add(const LoadWaiterTipsEvent());
    _waiterBloc.stream.listen((state) {
      if (!mounted) return;
      if (state is WaiterTipsLoaded) {
        setState(() => _tipsTotal = state.totalTips);
      }
    });
    _pushSubscription = getIt<PushNotificationService>().messages.listen(
      _handlePushMessage,
    );
  }

  @override
  void dispose() {
    _waiterBloc.close();
    _pushSubscription.cancel();
    super.dispose();
  }

  void _handlePushMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type']?.toString().toLowerCase();

    if (type == 'table_help' || type == 'help_request') {
      _handleHelpRequest(data, message);
    } else {
      _handlePayment(data, message);
    }
  }

  void _handleHelpRequest(Map<String, dynamic> data, RemoteMessage message) {
    final tableId =
        data['tableId']?.toString() ?? data['table']?.toString() ?? '';
    final tableName =
        data['tableName']?.toString() ??
        data['table_name']?.toString() ??
        (tableId.isNotEmpty ? 'Mesa ${data['tableNumber']}' : 'Mesa');
    final helpMessage =
        data['message']?.toString() ??
        data['content']?.toString() ??
        message.notification?.body ??
        'Requiere ayuda';

    setState(() {
      _helpAlerts.insert(
        0,
        _TableHelpAlert(
          tableId: tableId,
          tableName: tableName,
          message: helpMessage,
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  void _handlePayment(Map<String, dynamic> data, RemoteMessage message) {
    final tipsTotal = _parseMoney(
      data['tipsTotal'] ?? data['totalTips'] ?? data['tips_total'],
    );
    final tipAmount = _parseMoney(
      data['tipAmount'] ?? data['tip'] ?? data['tip_amount'],
    );

    if (tipsTotal == null && tipAmount == null) return;

    setState(() {
      if (tipsTotal != null) {
        _tipsTotal = tipsTotal;
      } else if (tipAmount != null) {
        _tipsTotal += tipAmount;
      }
    });

    final title =
        message.notification?.title ??
        data['title']?.toString() ??
        'Nuevo pago recibido';
    final body =
        message.notification?.body ??
        data['message']?.toString() ??
        'Un cliente realizó un pago.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(body, style: const TextStyle(fontSize: 13)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  double? _parseMoney(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text(
          'Módulo de mesero',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _TipsSummaryCard(total: _tipsTotal),
            const SizedBox(height: 16),
            _HelpAlertsSection(
              alerts: _helpAlerts,
              onResolve: (index) {
                setState(() => _helpAlerts.removeAt(index));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TipsSummaryCard extends StatelessWidget {
  final double total;

  const _TipsSummaryCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payments_outlined, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'Ganancia en propinas',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              '\$${total.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Actualizado automáticamente por notificaciones push',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpAlertsSection extends StatelessWidget {
  final List<_TableHelpAlert> alerts;
  final ValueChanged<int> onResolve;

  const _HelpAlertsSection({required this.alerts, required this.onResolve});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_active_outlined,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mesas que requieren ayuda',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (alerts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No hay solicitudes pendientes',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            else
              ...alerts.asMap().entries.map((entry) {
                final index = entry.key;
                final alert = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == alerts.length - 1 ? 0 : 10,
                  ),
                  child: _HelpAlertTile(
                    alert: alert,
                    onResolve: () => onResolve(index),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _HelpAlertTile extends StatelessWidget {
  final _TableHelpAlert alert;
  final VoidCallback onResolve;

  const _HelpAlertTile({required this.alert, required this.onResolve});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.table_restaurant,
                  color: Colors.orange.shade800,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.tableName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    Text(
                      _formatTime(alert.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Marcar atendida',
                onPressed: onResolve,
                icon: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade700,
                  size: 28,
                ),
              ),
            ],
          ),
          if (alert.message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Text(
                alert.message,
                style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _TableHelpAlert {
  final String tableId;
  final String tableName;
  final String message;
  final DateTime createdAt;

  const _TableHelpAlert({
    required this.tableId,
    required this.tableName,
    required this.message,
    required this.createdAt,
  });
}
