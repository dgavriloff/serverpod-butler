import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../services/cookie_web.dart';

/// Home screen with join room and create room options
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Join form
  final _joinRoomController = TextEditingController();
  final _joinGroupController = TextEditingController();

  // Create form
  final _createFormKey = GlobalKey<FormState>();
  final _createTagController = TextEditingController();
  final _createNameController = TextEditingController();
  final _createRoomCountController = TextEditingController(text: '4');

  bool _isCreating = false;
  String? _createError;

  @override
  void dispose() {
    _joinRoomController.dispose();
    _joinGroupController.dispose();
    _createTagController.dispose();
    _createNameController.dispose();
    _createRoomCountController.dispose();
    super.dispose();
  }

  void _joinRoom() {
    final room = _joinRoomController.text.trim().toLowerCase();
    final group = _joinGroupController.text.trim();
    if (room.isEmpty || group.isEmpty) return;

    Navigator.of(context).pushReplacementNamed('/$room/$group');
  }

  Future<void> _createRoom() async {
    if (!_createFormKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
      _createError = null;
    });

    try {
      final tag = _createTagController.text.trim().toLowerCase();
      final name = _createNameController.text.trim();
      final roomCount = int.parse(_createRoomCountController.text);

      final session = await client.session.createSession(
        name.isNotEmpty ? name : tag,
        roomCount,
      );

      final liveSession = await client.session.startLiveSession(
        session.id!,
        tag,
      );

      if (mounted) {
        final token = liveSession.creatorToken ?? '';
        CookieService.set('creator_$tag', token);
        Navigator.of(context).pushReplacementNamed('/$tag');
      }
    } catch (e) {
      setState(() {
        _createError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo/Title
                Icon(
                  Icons.school_rounded,
                  size: 64,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Breakout Butler',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Collaborative workspaces for your breakout rooms',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Join Room Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Join a Room',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _joinRoomController,
                          decoration: const InputDecoration(
                            labelText: 'Room Name',
                            hintText: 'e.g., psych101',
                            prefixIcon: Icon(Icons.meeting_room_outlined),
                            border: OutlineInputBorder(),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9\-_]')),
                          ],
                          onFieldSubmitted: (_) => _joinRoom(),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _joinGroupController,
                          decoration: const InputDecoration(
                            labelText: 'Group Number',
                            hintText: 'e.g., 1',
                            prefixIcon: Icon(Icons.group_outlined),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onFieldSubmitted: (_) => _joinRoom(),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _joinRoom,
                          icon: const Icon(Icons.login),
                          label: const Text('Join'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Create Room Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _createFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Create a Room',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _createTagController,
                            decoration: const InputDecoration(
                              labelText: 'Room Name',
                              hintText: 'e.g., psych101',
                              prefixIcon: Icon(Icons.link),
                              border: OutlineInputBorder(),
                              helperText: 'Students join at /psych101/1, /psych101/2, etc.',
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9\-_]')),
                              LengthLimitingTextInputFormatter(30),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a room name';
                              }
                              if (value.length < 3) {
                                return 'Room name must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _createNameController,
                            decoration: const InputDecoration(
                              labelText: 'Display Name (optional)',
                              hintText: 'e.g., Milgram Experiment Discussion',
                              prefixIcon: Icon(Icons.label_outline),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _createRoomCountController,
                            decoration: const InputDecoration(
                              labelText: 'Number of Groups',
                              prefixIcon: Icon(Icons.groups_outlined),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              final count = int.tryParse(value ?? '');
                              if (count == null || count < 1 || count > 50) {
                                return 'Enter a number between 1 and 50';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          if (_createError != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                _createError!,
                                style: TextStyle(color: colorScheme.error),
                              ),
                            ),

                          FilledButton.tonal(
                            onPressed: _isCreating ? null : _createRoom,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                            child: _isCreating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('Create Room'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
