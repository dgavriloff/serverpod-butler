import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Service for interacting with Gemini AI
class GeminiService {
  static GeminiService? _instance;
  late final GenerativeModel _model;
  late final GenerativeModel _flashModel;

  GeminiService._internal(String apiKey) {
    // Main model for Q&A and summarization
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
    );
    // Flash model for quick transcription
    _flashModel = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
    );
  }

  /// Initialize the service with API key
  static void initialize(String apiKey) {
    _instance = GeminiService._internal(apiKey);
  }

  /// Get the singleton instance
  static GeminiService get instance {
    if (_instance == null) {
      throw StateError('GeminiService not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  /// Transcribe audio data to text
  Future<String> transcribeAudio(Uint8List audioData, String mimeType) async {
    print('GeminiService: Transcribing ${audioData.length} bytes of $mimeType');
    try {
      final response = await _flashModel.generateContent([
        Content.multi([
          DataPart(mimeType, audioData),
          TextPart(
            'Transcribe this audio accurately. Return only the transcription, no additional commentary.',
          ),
        ]),
      ]);
      final text = response.text?.trim() ?? '';
      print('GeminiService: Transcription result: "$text"');
      return text;
    } catch (e) {
      print('GeminiService: Transcription error: $e');
      return '';
    }
  }

  /// Answer a question based on transcript context
  Future<String> answerQuestion(String question, String transcript) async {
    try {
      final response = await _model.generateContent([
        Content.text('''
You are a helpful classroom assistant called "Butler". A professor is giving a lecture and students are in breakout rooms. Your job is to help students understand what the professor said.

Based on the lecture transcript below, answer the student's question. Be concise and helpful. If you can't find relevant information in the transcript, say so politely.

LECTURE TRANSCRIPT:
$transcript

STUDENT'S QUESTION: $question

ANSWER:'''),
      ]);
      return response.text?.trim() ?? 'I couldn\'t generate a response.';
    } catch (e) {
      print('Q&A error: $e');
      return 'Sorry, I encountered an error processing your question.';
    }
  }

  /// Summarize room content
  Future<String> summarizeContent(String content, int roomNumber) async {
    if (content.trim().isEmpty) {
      return 'Room $roomNumber hasn\'t written anything yet.';
    }

    try {
      final response = await _model.generateContent([
        Content.text('''
Summarize what this breakout room group has written. Be concise (2-3 sentences max).

ROOM $roomNumber CONTENT:
$content

SUMMARY:'''),
      ]);
      return response.text?.trim() ?? 'Unable to summarize.';
    } catch (e) {
      print('Summary error: $e');
      return 'Error generating summary.';
    }
  }

  /// Extract or generate an assignment/prompt from transcript content
  Future<String?> extractAssignment(String transcript) async {
    if (transcript.trim().isEmpty) return null;

    try {
      final response = await _flashModel.generateContent([
        Content.text('''
You are helping a professor create a breakout room assignment for students.

Based on the content below, do ONE of the following:
1. If there's an explicit assignment, task, or question mentioned, extract it
2. If there's no explicit assignment but there's educational content, generate a thoughtful discussion question or task that students could work on related to the main topics

Keep the assignment concise (2-4 sentences max). Focus on what students should discuss, analyze, or produce.

CONTENT:
$transcript

ASSIGNMENT FOR STUDENTS:'''),
      ]);
      final result = response.text?.trim() ?? '';
      if (result.isEmpty) return null;
      return result;
    } catch (e) {
      print('[GeminiService.extractAssignment] ERROR: $e');
      return null;
    }
  }

  /// Generate a synthesis across multiple room contents
  Future<String> synthesizeRooms(Map<int, String> roomContents) async {
    if (roomContents.isEmpty) {
      return 'No room content to synthesize.';
    }

    final roomsText = roomContents.entries
        .map((e) => 'ROOM ${e.key}:\n${e.value}')
        .join('\n\n');

    try {
      final response = await _model.generateContent([
        Content.text('''
Analyze what each breakout room discussed and identify:
1. Common themes across rooms
2. Unique insights from specific rooms
3. Any contradictions or debates

Be concise but thorough.

$roomsText

SYNTHESIS:'''),
      ]);
      return response.text?.trim() ?? 'Unable to synthesize.';
    } catch (e) {
      print('Synthesis error: $e');
      return 'Error generating synthesis.';
    }
  }
}
