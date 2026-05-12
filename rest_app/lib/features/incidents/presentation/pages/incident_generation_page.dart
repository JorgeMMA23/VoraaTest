import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rest_app/core/di/injection.dart';

class IncidentGenerationPage extends StatefulWidget {
  final String orderId;

  const IncidentGenerationPage({super.key, required this.orderId});

  @override
  State<IncidentGenerationPage> createState() => _IncidentGenerationPageState();
}

class _IncidentGenerationPageState extends State<IncidentGenerationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final Dio _dio;
  late final FirebaseAuth _firebaseAuth;
  late final FirebaseFirestore _firestore;

  String? _incidentId;
  String? _incidentName;
  String? _incidentDescription;
  bool _isCreatingIncident = false;
  bool _isSendingMessage = false;

  @override
  void initState() {
    super.initState();
    _dio = getIt<Dio>();
    _firebaseAuth = getIt<FirebaseAuth>();
    _firestore = FirebaseFirestore.instance;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _createIncident() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    if (name.isEmpty || description.isEmpty || _isCreatingIncident) return;

    setState(() => _isCreatingIncident = true);

    try {
      final response = await _dio.post(
        '/api/incidents/',
        data: {
          'orderId': widget.orderId,
          'name': name,
          'title': name,
          'description': description,
        },
      );

      final data = response.data;
      final incidentId = _extractIncidentId(data);
      if (incidentId == null || incidentId.isEmpty) {
        throw Exception('La respuesta no incluyo el id de la incidencia.');
      }

      if (!mounted) return;
      setState(() {
        _incidentId = incidentId;
        _incidentName = name;
        _incidentDescription = description;
        _isCreatingIncident = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCreatingIncident = false);
      _showError('No se pudo generar la incidencia. Intenta nuevamente.');
    }
  }

  String? _extractIncidentId(dynamic data) {
    if (data is Map<String, dynamic>) {
      final id = data['id'] ?? data['_id'];
      if (id != null) return id.toString();

      final incident = data['incident'];
      if (incident is Map<String, dynamic>) {
        final nestedId = incident['id'] ?? incident['_id'];
        if (nestedId != null) return nestedId.toString();
      }
    }
    return null;
  }

  Future<void> _sendMessage() async {
    final incidentId = _incidentId;
    final content = _messageController.text.trim();
    if (incidentId == null || content.isEmpty || _isSendingMessage) return;

    final user = _firebaseAuth.currentUser;
    final authorId = user?.uid ?? 'anonymous';
    final authorName = user?.displayName ?? user?.email ?? 'Cliente';

    setState(() => _isSendingMessage = true);

    try {
      await _dio.post(
        '/api/incidents/$incidentId/messages',
        data: {
          'authorId': authorId,
          'authorName': authorName,
          'content': content,
        },
      );

      _messageController.clear();
    } catch (e) {
      if (!mounted) return;
      _showError('No se pudo enviar el mensaje.');
    } finally {
      if (mounted) setState(() => _isSendingMessage = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: context.canPop()
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/orders'),
              ),
        title: const Text(
          'Generar incidencia',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _incidentId == null ? _buildIncidentForm() : _buildIncidentChat(),
    );
  }

  Widget _buildIncidentForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.report_problem_outlined,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Incidencia del pedido',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Orden ${widget.orderId}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Nombre de la incidencia',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Describe la incidencia',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _isCreatingIncident ? null : _createIncident,
            icon: _isCreatingIncident
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_outlined),
            label: Text(
              _isCreatingIncident ? 'Generando...' : 'Generar incidencia',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.green.shade200,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentChat() {
    final currentUserId = _firebaseAuth.currentUser?.uid;
    final incidentId = _incidentId;
    if (incidentId == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _incidentName ?? 'Incidencia',
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _incidentDescription ?? '',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Orden ${widget.orderId} · Incidencia $incidentId',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _firestore
                .collection('incidents')
                .doc(incidentId)
                .collection('messages')
                .orderBy('createdAt')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'No se pudieron cargar los mensajes',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final messages =
                  snapshot.data?.docs
                      .map((doc) => _IncidentMessage.fromJson(doc.data()))
                      .toList() ??
                  [];

              if (messages.isEmpty) {
                return Center(
                  child: Text(
                    'Sin mensajes todavía',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                );
              }

              _scrollToBottom();

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isMine = message.authorId == currentUserId;
                  return _MessageBubble(message: message, isMine: isMine);
                },
              );
            },
          ),
        ),
/*
          child: _messages.isEmpty
              ? Center(
                  child: Text(
                    'Sin mensajes todavía',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isMine = message.authorId == currentUserId;
                    return _MessageBubble(message: message, isMine: isMine);
                  },
                ),
        ),
*/
        SafeArea(
          top: false,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isSendingMessage ? null : _sendMessage,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    disabledBackgroundColor: Colors.green.shade200,
                  ),
                  icon: _isSendingMessage
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IncidentMessage {
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;

  const _IncidentMessage({
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  factory _IncidentMessage.fromJson(Map<String, dynamic> json) {
    return _IncidentMessage(
      authorId: json['authorId']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? 'Soporte',
      content: json['content']?.toString() ?? '',
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is Map<String, dynamic>) {
      final seconds = value['_seconds'];
      final nanoseconds = value['_nanoseconds'];
      if (seconds is int && nanoseconds is int) {
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + nanoseconds ~/ 1000000,
          isUtc: true,
        ).toLocal();
      }
    }
    return DateTime.now();
  }
}

class _MessageBubble extends StatelessWidget {
  final _IncidentMessage message;
  final bool isMine;

  const _MessageBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? Colors.green.shade700 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.authorName,
              style: TextStyle(
                color: isMine ? Colors.white70 : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.content,
              style: TextStyle(
                color: isMine ? Colors.white : Colors.grey.shade900,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                color: isMine ? Colors.white70 : Colors.grey.shade500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
