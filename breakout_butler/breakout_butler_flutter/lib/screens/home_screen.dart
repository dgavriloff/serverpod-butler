import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';

/// Home screen for professors to create new sessions
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _promptController = TextEditingController();
  final _urlTagController = TextEditingController();
  final _roomCountController = TextEditingController(text: '4');

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _promptController.dispose();
    _urlTagController.dispose();
    _roomCountController.dispose();
    super.dispose();
  }

  Future<void> _createSession() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Create the session
      final session = await client.session.createSession(
        _nameController.text.trim(),
        _promptController.text.trim(),
        int.parse(_roomCountController.text),
      );

      // Start the live session with URL tag
      await client.session.startLiveSession(
        session.id!,
        _urlTagController.text.trim().toLowerCase(),
      );

      if (mounted) {
        // Navigate to professor dashboard
        Navigator.of(context).pushReplacementNamed(
          '/${_urlTagController.text.trim().toLowerCase()}',
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
                  'Create collaborative workspaces for your breakout rooms',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Form
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Start a New Session',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 24),

                          // Session Name
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Session Name',
                              hintText: 'e.g., Milgram Discussion',
                              prefixIcon: Icon(Icons.label_outline),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a session name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // URL Tag
                          TextFormField(
                            controller: _urlTagController,
                            decoration: const InputDecoration(
                              labelText: 'URL Tag',
                              hintText: 'e.g., psych101',
                              prefixIcon: Icon(Icons.link),
                              border: OutlineInputBorder(),
                              helperText: 'Students will join at /psych101/1, /psych101/2, etc.',
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-_]')),
                              LengthLimitingTextInputFormatter(30),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a URL tag';
                              }
                              if (value.length < 3) {
                                return 'URL tag must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Prompt
                          TextFormField(
                            controller: _promptController,
                            decoration: const InputDecoration(
                              labelText: 'Breakout Room Prompt',
                              hintText: 'What should students discuss?',
                              prefixIcon: Icon(Icons.assignment_outlined),
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a prompt for the breakout rooms';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Room Count
                          TextFormField(
                            controller: _roomCountController,
                            decoration: const InputDecoration(
                              labelText: 'Number of Rooms',
                              prefixIcon: Icon(Icons.meeting_room_outlined),
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
                          const SizedBox(height: 24),

                          // Error
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                _error!,
                                style: TextStyle(color: colorScheme.error),
                              ),
                            ),

                          // Submit Button
                          FilledButton.icon(
                            onPressed: _isLoading ? null : _createSession,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.rocket_launch),
                            label: Text(_isLoading ? 'Creating...' : 'Start Session'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
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
