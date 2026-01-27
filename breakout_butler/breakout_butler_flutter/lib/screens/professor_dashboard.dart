import 'dart:async';
import 'dart:typed_data';
import 'package:breakout_butler_client/breakout_butler_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../services/audio_recorder_web.dart';
import '../services/speech_recognition_web.dart';
import '../widgets/audio_visualizer.dart';

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

  /// Current interim (partial) speech recognition text, shown in italic.
  String _interimText = '';

  /// Whether we're using Web Speech API (true) or Gemini fallback (false).
  bool _usingSpeechApi = false;

  /// Whether Gemini is currently processing an audio chunk (fallback mode).
  bool _isTranscribing = false;

  /// Queue of audio chunks waiting for Gemini transcription (fallback mode).
  final List<Uint8List> _audioQueue = [];

  StreamSubscription? _roomSubscription;
  StreamSubscription? _transcriptSubscription;
  StreamSubscription? _speechSubscription;
  StreamSubscription? _audioChunkSubscription;

  final _transcriptController = TextEditingController();
  final _transcriptScrollController = ScrollController();
  AudioRecorderService? _audioRecorder;
  SpeechRecognitionService? _speechRecognition;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _audioRecorder = AudioRecorderService();
      // _speechRecognition is created lazily in _toggleRecording
      // based on Web Speech API availability
    }
    _loadSession();
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    _transcriptSubscription?.cancel();
    _speechSubscription?.cancel();
    _audioChunkSubscription?.cancel();
    _audioRecorder?.dispose();
    _speechRecognition?.dispose();
    _transcriptController.dispose();
    _transcriptScrollController.dispose();
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

      // Subscribe to transcript updates from server (Redis broadcast)
      _transcriptSubscription = client.butler
          .transcriptStream(_liveSession!.sessionId)
          .listen((update) {
        setState(() {
          _transcriptChunks.add(update.text);
        });
        _scrollTranscriptToBottom();
      });
    } catch (e) {
      // Streaming might not be available yet
      debugPrint('Streaming error: $e');
    }
  }

  void _scrollTranscriptToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_transcriptScrollController.hasClients) {
        _transcriptScrollController.animateTo(
          _transcriptScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _addTranscript() async {
    final text = _transcriptController.text.trim();
    if (text.isEmpty || _liveSession == null) return;

    try {
      await client.butler.addTranscriptText(_liveSession!.sessionId, text);
      _transcriptController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// Toggle audio recording + transcription on/off.
  /// Uses Web Speech API if available (live interim results),
  /// otherwise falls back to MediaRecorder + Gemini server-side transcription.
  Future<void> _toggleRecording() async {
    debugPrint('[_toggleRecording] called, _isRecording=$_isRecording');
    if (_audioRecorder == null || _liveSession == null) {
      debugPrint('[_toggleRecording] ABORT: audioRecorder or session is null');
      return;
    }

    if (_isRecording) {
      // Stop everything
      _speechRecognition?.stop();
      _speechSubscription?.cancel();
      _speechSubscription = null;
      _audioChunkSubscription?.cancel();
      _audioChunkSubscription = null;
      await _audioRecorder!.stopRecording();
      _audioQueue.clear();
      setState(() {
        _isRecording = false;
        _interimText = '';
        _isTranscribing = false;
      });
      debugPrint('[_toggleRecording] stopped');
    } else {
      // Detect which transcription mode to use
      final speechApiAvailable = SpeechRecognitionService.isSupported;
      _usingSpeechApi = speechApiAvailable;
      debugPrint('[_toggleRecording] Web Speech API available: $speechApiAvailable');

      // Start audio service (visualizer always, MediaRecorder only for fallback)
      final vizError = await _audioRecorder!.startRecording(
        enableRecorder: !speechApiAvailable,
      );
      if (vizError != null) {
        debugPrint('[_toggleRecording] audio service error: $vizError');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(vizError), duration: const Duration(seconds: 5)),
          );
        }
        return;
      }

      if (speechApiAvailable) {
        // Primary path: Web Speech API
        _speechRecognition ??= SpeechRecognitionService();
        final speechError = _speechRecognition!.start();
        if (speechError != null) {
          debugPrint('[_toggleRecording] speech recognition error: $speechError');
          await _audioRecorder!.stopRecording();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(speechError), duration: const Duration(seconds: 5)),
            );
          }
          return;
        }

        // Listen to speech recognition results
        _speechSubscription = _speechRecognition!.resultStream.listen(
          (result) {
            if (result.isFinal) {
              final text = result.text.trim();
              if (text.isNotEmpty && _liveSession != null) {
                debugPrint('[speech] final: "$text"');
                client.butler.addTranscriptText(_liveSession!.sessionId, text);
              }
              setState(() => _interimText = '');
            } else {
              setState(() => _interimText = result.text);
              _scrollTranscriptToBottom();
            }
          },
          onError: (error) {
            debugPrint('[speech] stream error: $error');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Speech recognition: $error')),
              );
            }
          },
        );
        debugPrint('[_toggleRecording] started with Web Speech API');
      } else {
        // Fallback path: MediaRecorder chunks → Gemini server-side transcription
        _audioChunkSubscription = _audioRecorder!.audioStream.listen(
          (chunk) {
            _audioQueue.add(chunk);
            _drainAudioQueue();
          },
        );
        debugPrint('[_toggleRecording] started with Gemini fallback (MediaRecorder)');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Using server-side transcription (Web Speech API not available in this browser).'),
              duration: Duration(seconds: 4),
            ),
          );
        }
      }

      setState(() => _isRecording = true);
    }
  }

  /// Drain the audio queue one chunk at a time, sending each to Gemini.
  Future<void> _drainAudioQueue() async {
    if (_isTranscribing || _audioQueue.isEmpty || _liveSession == null) return;
    _isTranscribing = true;

    while (_audioQueue.isNotEmpty && _isRecording) {
      final chunk = _audioQueue.removeAt(0);
      try {
        debugPrint('[gemini-fallback] sending ${chunk.length} bytes...');
        final text = await client.butler.processAudio(
          _liveSession!.sessionId,
          ByteData.view(chunk.buffer),
          'audio/webm;codecs=opus',
        );
        if (text.isNotEmpty) {
          debugPrint('[gemini-fallback] transcribed: "$text"');
        }
      } catch (e) {
        debugPrint('[gemini-fallback] error: $e');
      }
    }

    _isTranscribing = false;
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;

          if (isWide) {
            // Desktop layout with side-by-side panels
            return Row(
              children: [
                Expanded(flex: 2, child: _buildRoomsPanel(colorScheme, roomCount)),
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: colorScheme.outlineVariant)),
                  ),
                  child: _buildTranscriptPanel(colorScheme),
                ),
              ],
            );
          } else {
            // Mobile layout with bottom sheet for transcript
            return Stack(
              children: [
                _buildRoomsPanel(colorScheme, roomCount),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildMobileTranscriptBar(colorScheme),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildRoomsPanel(ColorScheme colorScheme, int roomCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: colorScheme.primaryContainer,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                '/${widget.urlTag}/[room#]',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: _synthesizeAllRooms,
                icon: const Icon(Icons.auto_awesome, size: 16),
                label: const Text('Synthesize'),
              ),
            ],
          ),
        ),
        // Rooms grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
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
                                color: hasContent ? colorScheme.primary : colorScheme.outline,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Room $roomNumber',
                                  style: Theme.of(context).textTheme.titleSmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (hasContent)
                                Icon(Icons.edit_note, size: 14, color: colorScheme.primary),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Text(
                              hasContent ? content : 'No activity...',
                              style: TextStyle(
                                fontSize: 11,
                                color: hasContent ? colorScheme.onSurface : colorScheme.outline,
                              ),
                              maxLines: 5,
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
    );
  }

  Widget _buildTranscriptPanel(ColorScheme colorScheme) {
    final hasContent = _transcriptChunks.isNotEmpty || _interimText.isNotEmpty;

    return Column(
      children: [
        // Transcript header
        Container(
          padding: const EdgeInsets.all(12),
          color: colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Icon(
                _isRecording ? Icons.mic : Icons.mic_none,
                color: _isRecording ? Colors.red : colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Live Transcript', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    if (_isRecording && _audioRecorder != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AudioVisualizer(
                            audioLevelStream: _audioRecorder!.audioLevelStream,
                            width: 100,
                            height: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _usingSpeechApi ? 'Listening...' : 'Transcribing (server)...',
                            style: const TextStyle(fontSize: 10, color: Colors.red),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: kIsWeb ? _toggleRecording : null,
                icon: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record, size: 14),
                label: Text(_isRecording ? 'Stop' : 'Rec'),
                style: FilledButton.styleFrom(
                  backgroundColor: _isRecording ? Colors.red : colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ),
        // Transcript content
        Expanded(
          child: !hasContent
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.record_voice_over_outlined, size: 48, color: colorScheme.outline),
                      const SizedBox(height: 8),
                      Text('No transcript yet', style: TextStyle(color: colorScheme.outline)),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _transcriptScrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _transcriptChunks.length + (_interimText.isNotEmpty ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < _transcriptChunks.length) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(_transcriptChunks[index]),
                      );
                    } else {
                      // Interim text — visually distinct
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _interimText,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    }
                  },
                ),
        ),
        // Manual transcript input
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _transcriptController,
                  decoration: const InputDecoration(hintText: 'Add text...', border: OutlineInputBorder(), isDense: true),
                  onSubmitted: (_) => _addTranscript(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(icon: const Icon(Icons.send), onPressed: _addTranscript),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTranscriptBar(ColorScheme colorScheme) {
    final displayText = _interimText.isNotEmpty
        ? _interimText
        : (_transcriptChunks.isNotEmpty ? _transcriptChunks.last : 'No transcript');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_isRecording && _audioRecorder != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AudioVisualizer(
                  audioLevelStream: _audioRecorder!.audioLevelStream,
                  width: 60,
                  height: 20,
                ),
              ),
            Expanded(
              child: Text(
                displayText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface,
                  fontStyle: _interimText.isNotEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: kIsWeb ? _toggleRecording : null,
              icon: Icon(_isRecording ? Icons.stop : Icons.mic, size: 16),
              label: Text(_isRecording ? 'Stop' : 'Rec'),
              style: FilledButton.styleFrom(
                backgroundColor: _isRecording ? Colors.red : colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ],
        ),
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
