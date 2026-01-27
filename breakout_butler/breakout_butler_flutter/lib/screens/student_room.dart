import 'dart:async';
import 'package:breakout_butler_client/breakout_butler_client.dart';
import 'package:flutter/material.dart';
import '../main.dart';

/// Student's breakout room workspace
class StudentRoom extends StatefulWidget {
  final String urlTag;
  final int roomNumber;

  const StudentRoom({
    super.key,
    required this.urlTag,
    required this.roomNumber,
  });

  @override
  State<StudentRoom> createState() => _StudentRoomState();
}

class _StudentRoomState extends State<StudentRoom> {
  LiveSession? _liveSession;
  ClassSession? _classSession;
  String _content = '';
  List<String> _transcriptChunks = [];
  bool _isLoading = true;
  String? _error;
  bool _isSaving = false;

  final _contentController = TextEditingController();
  final _questionController = TextEditingController();

  StreamSubscription? _roomSubscription;
  StreamSubscription? _transcriptSubscription;
  Timer? _saveDebounce;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    _transcriptSubscription?.cancel();
    _saveDebounce?.cancel();
    _contentController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _loadSession() async {
    try {
      final liveSession = await client.session.getLiveSessionByTag(widget.urlTag);
      if (liveSession == null) {
        setState(() {
          _error = 'Session not found or has ended.';
          _isLoading = false;
        });
        return;
      }

      final classSession = await client.session.getSession(liveSession.sessionId);
      final room = await client.room.getRoom(liveSession.sessionId, widget.roomNumber);

      setState(() {
        _liveSession = liveSession;
        _classSession = classSession;
        _content = room?.content ?? '';
        _contentController.text = _content;
        _isLoading = false;
        if (liveSession.transcript.isNotEmpty) {
          _transcriptChunks = [liveSession.transcript];
        }
      });

      _subscribeToUpdates();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _subscribeToUpdates() async {
    if (_liveSession == null) return;

    try {
      await client.openStreamingConnection();

      // Subscribe to room updates
      _roomSubscription = client.room
          .roomUpdates(_liveSession!.sessionId, widget.roomNumber)
          .listen((update) {
        // Only update if content is different (avoid overwriting during typing)
        if (update.content != _content && !_contentController.text.endsWith(update.content)) {
          setState(() {
            _content = update.content;
            // Only update controller if user isn't actively typing
            if (_contentController.text == _content) {
              _contentController.text = update.content;
            }
          });
        }
      });

      // Subscribe to transcript updates
      _transcriptSubscription = client.butler
          .transcriptStream(_liveSession!.sessionId)
          .listen((update) {
        setState(() {
          _transcriptChunks.add(update.text);
        });
      });
    } catch (e) {
      debugPrint('Streaming error: $e');
    }
  }

  void _onContentChanged(String value) {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      _saveContent(value);
    });
  }

  Future<void> _saveContent(String content) async {
    if (_liveSession == null || content == _content) return;

    setState(() => _isSaving = true);
    try {
      await client.room.updateRoomContent(
        _liveSession!.sessionId,
        widget.roomNumber,
        content,
      );
      _content = content;
    } catch (e) {
      debugPrint('Save error: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _askButler() async {
    final question = _questionController.text.trim();
    if (question.isEmpty || _liveSession == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Asking Butler...'),
          ],
        ),
      ),
    );

    try {
      final response = await client.butler.askButler(
        _liveSession!.sessionId,
        question,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _questionController.clear();

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.smart_toy, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Butler'),
              ],
            ),
            content: Text(response.answer),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Thanks!'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(_error!, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Make sure the professor has started the session.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Room ${widget.roomNumber}'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(Icons.cloud_done, color: colorScheme.primary, size: 20),
            ),
        ],
      ),
      body: Row(
        children: [
          // Left side: Collaborative document
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Prompt banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: colorScheme.primaryContainer,
                  child: Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: colorScheme.onPrimaryContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ask the Butler "What\'s my assignment?" to get your task from the lecture',
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Document editor
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: 'Start writing your group\'s ideas here...\n\nThis document is shared with everyone in Room ${widget.roomNumber}.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLowest,
                      ),
                      style: const TextStyle(fontSize: 16, height: 1.5),
                      onChanged: _onContentChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right side: Butler panel
          Container(
            width: 320,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Column(
              children: [
                // Butler header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: colorScheme.secondaryContainer,
                  child: Row(
                    children: [
                      Icon(Icons.smart_toy, color: colorScheme.onSecondaryContainer),
                      const SizedBox(width: 8),
                      Text(
                        'Butler',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),

                // Lecture context
                Expanded(
                  child: _transcriptChunks.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.record_voice_over_outlined,
                                  size: 48,
                                  color: colorScheme.outline,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Lecture context will appear here',
                                  style: TextStyle(color: colorScheme.outline),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Butler is listening to your professor...',
                                  style: TextStyle(
                                    color: colorScheme.outline,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Text(
                              'From the lecture:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._transcriptChunks.map(
                              (chunk) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  chunk,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),

                // Ask Butler input
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: colorScheme.outlineVariant),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Ask Butler',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _questionController,
                        decoration: InputDecoration(
                          hintText: 'What did she say about...?',
                          border: const OutlineInputBorder(),
                          isDense: true,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _askButler,
                          ),
                        ),
                        onSubmitted: (_) => _askButler(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
