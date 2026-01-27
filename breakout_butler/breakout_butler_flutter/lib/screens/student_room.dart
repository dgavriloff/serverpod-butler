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
  bool _isLoading = true;
  String? _error;
  bool _isSaving = false;

  final _contentController = TextEditingController();

  StreamSubscription? _roomSubscription;
  Timer? _saveDebounce;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    _saveDebounce?.cancel();
    _contentController.dispose();
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
      body: Padding(
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
    );
  }
}
