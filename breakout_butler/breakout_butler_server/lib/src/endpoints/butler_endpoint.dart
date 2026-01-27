import 'dart:async';
import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/gemini_service.dart';

/// Endpoint for butler AI features - transcription and Q&A
class ButlerEndpoint extends Endpoint {
  // Channel for transcript updates
  static String _transcriptChannel(int sessionId) => 'transcript-$sessionId';

  /// Stream transcript updates to all connected clients
  Stream<TranscriptUpdate> transcriptStream(
    Session session,
    int sessionId,
  ) async* {
    // Send current transcript first
    final liveSession = await LiveSession.db.findFirstRow(
      session,
      where: (t) => t.sessionId.equals(sessionId) & t.isActive.equals(true),
    );

    if (liveSession != null && liveSession.transcript.isNotEmpty) {
      yield TranscriptUpdate(
        text: liveSession.transcript,
        timestamp: DateTime.now(),
      );
    }

    // Then stream updates
    final updateStream = session.messages.createStream<TranscriptUpdate>(
      _transcriptChannel(sessionId),
    );

    await for (var update in updateStream) {
      yield update;
    }
  }

  /// Process audio chunk and transcribe using Gemini
  Future<String> processAudio(
    Session session,
    int sessionId,
    ByteData audioData,
    String mimeType,
  ) async {
    final audioBytes = audioData.buffer.asUint8List();
    print('[processAudio] START sessionId=$sessionId, ${audioBytes.length} bytes, mimeType=$mimeType');

    try {
      print('[processAudio] calling GeminiService.transcribeAudio...');
      final transcribedText = await GeminiService.instance.transcribeAudio(
        audioBytes,
        mimeType,
      );
      print('[processAudio] transcription result: "${transcribedText.length > 100 ? '${transcribedText.substring(0, 100)}...' : transcribedText}"');

      if (transcribedText.isNotEmpty) {
        print('[processAudio] calling addTranscriptText...');
        await addTranscriptText(session, sessionId, transcribedText);
        print('[processAudio] addTranscriptText done');
      }

      print('[processAudio] SUCCESS returning text');
      return transcribedText;
    } catch (e, st) {
      print('[processAudio] ERROR: $e');
      print('[processAudio] STACK: $st');
      session.log('processAudio error: $e\n$st', level: LogLevel.error);
      return '';
    }
  }

  /// Manually add text to transcript (useful for testing and demo)
  Future<void> addTranscriptText(
    Session session,
    int sessionId,
    String text,
  ) async {
    print('[addTranscriptText] START sessionId=$sessionId, text="${text.length > 50 ? '${text.substring(0, 50)}...' : text}"');

    // Get current live session
    print('[addTranscriptText] querying LiveSession...');
    final liveSession = await LiveSession.db.findFirstRow(
      session,
      where: (t) => t.sessionId.equals(sessionId) & t.isActive.equals(true),
    );
    print('[addTranscriptText] liveSession found: ${liveSession != null} (id=${liveSession?.id})');

    if (liveSession == null) {
      print('[addTranscriptText] ERROR: No active live session!');
      throw Exception('No active live session found');
    }

    // Append to transcript
    print('[addTranscriptText] updating transcript in DB...');
    liveSession.transcript = '${liveSession.transcript}\n$text'.trim();
    await LiveSession.db.updateRow(session, liveSession);
    print('[addTranscriptText] DB update done');

    // Store as chunk for searchability
    print('[addTranscriptText] inserting TranscriptChunk...');
    await TranscriptChunk.db.insertRow(
      session,
      TranscriptChunk(
        sessionId: sessionId,
        timestamp: DateTime.now(),
        text: text,
      ),
    );
    print('[addTranscriptText] chunk inserted');

    // Broadcast update (non-fatal if messaging fails)
    try {
      print('[addTranscriptText] broadcasting via Redis...');
      final update = TranscriptUpdate(
        text: text,
        timestamp: DateTime.now(),
      );
      session.messages.postMessage(
        _transcriptChannel(sessionId),
        update,
      );
      print('[addTranscriptText] broadcast done');
    } catch (e) {
      print('[addTranscriptText] BROADCAST FAILED: $e');
      session.log('Broadcast failed (Redis may be down): $e',
          level: LogLevel.warning);
    }
    print('[addTranscriptText] END');
  }

  /// Ask the butler a question about the transcript - uses Gemini AI
  Future<ButlerResponse> askButler(
    Session session,
    int sessionId,
    String question,
  ) async {
    // Get current transcript
    final liveSession = await LiveSession.db.findFirstRow(
      session,
      where: (t) => t.sessionId.equals(sessionId) & t.isActive.equals(true),
    );

    if (liveSession == null) {
      return ButlerResponse(
        answer: '',
        success: false,
        error: 'No active session found',
      );
    }

    if (liveSession.transcript.isEmpty) {
      return ButlerResponse(
        answer: 'No lecture content has been captured yet. The professor hasn\'t started speaking or the transcript is still being processed.',
        success: true,
      );
    }

    // Use Gemini for intelligent Q&A
    try {
      final answer = await GeminiService.instance.answerQuestion(
        question,
        liveSession.transcript,
      );
      return ButlerResponse(
        answer: answer,
        success: true,
      );
    } catch (e) {
      return ButlerResponse(
        answer: '',
        success: false,
        error: 'Error processing question: $e',
      );
    }
  }

  /// Summarize a specific room's content using Gemini
  Future<ButlerResponse> summarizeRoom(
    Session session,
    int sessionId,
    int roomNumber,
  ) async {
    final room = await Room.db.findFirstRow(
      session,
      where: (t) =>
          t.sessionId.equals(sessionId) & t.roomNumber.equals(roomNumber),
    );

    if (room == null) {
      return ButlerResponse(
        answer: '',
        success: false,
        error: 'Room not found',
      );
    }

    try {
      final summary = await GeminiService.instance.summarizeContent(
        room.content,
        roomNumber,
      );
      return ButlerResponse(
        answer: summary,
        success: true,
      );
    } catch (e) {
      return ButlerResponse(
        answer: '',
        success: false,
        error: 'Error summarizing room: $e',
      );
    }
  }

  /// Synthesize insights across all rooms
  Future<ButlerResponse> synthesizeAllRooms(
    Session session,
    int sessionId,
  ) async {
    final rooms = await Room.db.find(
      session,
      where: (t) => t.sessionId.equals(sessionId),
      orderBy: (t) => t.roomNumber,
    );

    final roomContents = <int, String>{};
    for (var room in rooms) {
      if (room.content.isNotEmpty) {
        roomContents[room.roomNumber] = room.content;
      }
    }

    if (roomContents.isEmpty) {
      return ButlerResponse(
        answer: 'No rooms have content to synthesize yet.',
        success: true,
      );
    }

    try {
      final synthesis = await GeminiService.instance.synthesizeRooms(roomContents);
      return ButlerResponse(
        answer: synthesis,
        success: true,
      );
    } catch (e) {
      return ButlerResponse(
        answer: '',
        success: false,
        error: 'Error synthesizing rooms: $e',
      );
    }
  }

  /// Try to extract assignment from transcript
  Future<String?> extractAssignment(
    Session session,
    int sessionId,
  ) async {
    final liveSession = await LiveSession.db.findFirstRow(
      session,
      where: (t) => t.sessionId.equals(sessionId) & t.isActive.equals(true),
    );

    if (liveSession == null || liveSession.transcript.isEmpty) {
      return null;
    }

    return await GeminiService.instance.extractAssignment(liveSession.transcript);
  }
}
