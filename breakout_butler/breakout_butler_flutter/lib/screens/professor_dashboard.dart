import 'dart:async';
import 'package:breakout_butler_client/breakout_butler_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';

/// Professor's dashboard showing all breakout rooms
class ProfessorDashboard extends StatefulWidget {
  final String urlTag;

  const ProfessorDashboard({super.key, required this.urlTag});

  @override
  State<ProfessorDashboard> createState() => _ProfessorDashboardState();
}

class _ProfessorDashboardState extends State<ProfessorDashboard> {
  LiveSession? _liveSession;
  ClassSession? _classSession;
  Map<int, String> _roomContents = {};
  List<String> _transcriptChunks = [];
  bool _isLoading = true;
  String? _error;
  bool _isRecording = false;

  StreamSubscription? _roomSubscription;
  StreamSubscription? _transcriptSubscription;

  final _transcriptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    _transcriptSubscription?.cancel();
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _loadSession() async {
    try {
      final liveSession = await client.session.getLiveSessionByTag(widget.urlTag);
      if (liveSession == null) {
        setState(() {
          _error = 'Session not found. It may have ended.';
          _isLoading = false;
        });
        return;
      }

      final classSession = await client.session.getSession(liveSession.sessionId);

      setState(() {
        _liveSession = liveSession;
        _classSession = classSession;
        _isLoading = false;
        if (liveSession.transcript.isNotEmpty) {
          _transcriptChunks = [liveSession.transcript];
        }
      });

      // Initialize room contents
      if (classSession?.rooms != null) {
        for (var room in classSession!.rooms!) {
          _roomContents[room.roomNumber] = room.content;
        }
      }

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

    // Subscribe to room updates
    try {
      await client.openStreamingConnection();

      _roomSubscription = client.room
          .allRoomUpdates(_liveSession!.sessionId)
          .listen((update) {
        setState(() {
          _roomContents[update.roomNumber] = update.content;
        });
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
      // Streaming might not be available yet
      debugPrint('Streaming error: $e');
    }
  }

  Future<void> _addTranscript() async {
    final text = _transcriptController.text.trim();
    if (text.isEmpty || _liveSession == null) return;

    try {
      await client.butler.addTranscriptText(_liveSession!.sessionId, text);
      _transcriptController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _synthesizeAllRooms() async {
    if (_liveSession == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Butler is synthesizing all rooms...'),
          ],
        ),
      ),
    );

    try {
      final response = await client.butler.synthesizeAllRooms(_liveSession!.sessionId);
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Cross-Room Synthesis'),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Text(response.answer),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
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

  Future<void> _endSession() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text('This will deactivate the URL tag. Room contents will be preserved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End Session'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await client.session.endLiveSession(widget.urlTag);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
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
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final roomCount = _classSession?.roomCount ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_classSession?.name ?? 'Session'),
        actions: [
          // Copy URL button
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy student URL',
            onPressed: () {
              final baseUrl = Uri.base.origin;
              Clipboard.setData(ClipboardData(text: '$baseUrl/${widget.urlTag}/'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('URL copied! Share with students.')),
              );
            },
          ),
          // End session button
          IconButton(
            icon: const Icon(Icons.stop_circle_outlined),
            tooltip: 'End session',
            onPressed: _endSession,
          ),
        ],
      ),
      body: Row(
        children: [
          // Left side: Rooms grid
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prompt:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _classSession?.prompt ?? '',
                        style: TextStyle(color: colorScheme.onPrimaryContainer),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Students join: /${widget.urlTag}/[room#]',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                            ),
                          ),
                          const Spacer(),
                          FilledButton.tonalIcon(
                            onPressed: _synthesizeAllRooms,
                            icon: const Icon(Icons.auto_awesome, size: 16),
                            label: const Text('Synthesize All Rooms'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Rooms grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: roomCount,
                      itemBuilder: (context, index) {
                        final roomNumber = index + 1;
                        final content = _roomContents[roomNumber] ?? '';
                        final hasContent = content.isNotEmpty;

                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _showRoomDetail(roomNumber, content),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.meeting_room,
                                        color: hasContent
                                            ? colorScheme.primary
                                            : colorScheme.outline,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Room $roomNumber',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      const Spacer(),
                                      if (hasContent)
                                        Icon(
                                          Icons.edit_note,
                                          size: 16,
                                          color: colorScheme.primary,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: Text(
                                      hasContent ? content : 'No activity yet...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: hasContent
                                            ? colorScheme.onSurface
                                            : colorScheme.outline,
                                      ),
                                      maxLines: 6,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right side: Transcript/Butler panel
          Container(
            width: 350,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Column(
              children: [
                // Transcript header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: colorScheme.surfaceContainerHighest,
                  child: Row(
                    children: [
                      Icon(Icons.mic, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Live Transcript',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      // Recording indicator (placeholder for actual mic capture)
                      IconButton(
                        icon: Icon(
                          _isRecording ? Icons.stop : Icons.fiber_manual_record,
                          color: _isRecording ? Colors.red : colorScheme.outline,
                        ),
                        onPressed: () {
                          setState(() => _isRecording = !_isRecording);
                          // TODO: Implement actual audio capture
                        },
                        tooltip: _isRecording ? 'Stop recording' : 'Start recording',
                      ),
                    ],
                  ),
                ),

                // Transcript content
                Expanded(
                  child: _transcriptChunks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.record_voice_over_outlined,
                                size: 48,
                                color: colorScheme.outline,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No transcript yet',
                                style: TextStyle(color: colorScheme.outline),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _transcriptChunks.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(_transcriptChunks[index]),
                            );
                          },
                        ),
                ),

                // Manual transcript input (for demo)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _transcriptController,
                          decoration: const InputDecoration(
                            hintText: 'Add transcript text (for demo)...',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _addTranscript(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _addTranscript,
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

  void _showRoomDetail(int roomNumber, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Room $roomNumber'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Text(content.isEmpty ? 'No content yet.' : content),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Ask butler to summarize
              final response = await client.butler.summarizeRoom(
                _liveSession!.sessionId,
                roomNumber,
              );
              if (mounted) {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Butler Summary'),
                    content: Text(response.answer),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Ask Butler to Summarize'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
