import 'dart:async';
import 'dart:js_interop';

/// JS interop bindings for the Web Speech API (Chrome).
/// Uses webkitSpeechRecognition which is the only widely-supported variant.
@JS('webkitSpeechRecognition')
extension type _JsSpeechRecognition._(JSObject _) implements JSObject {
  external factory _JsSpeechRecognition();
  external set continuous(bool value);
  external set interimResults(bool value);
  external set lang(String value);
  external set onresult(JSFunction? handler);
  external set onerror(JSFunction? handler);
  external set onend(JSFunction? handler);
  external void start();
  external void stop();
  external void abort();
}

@JS()
extension type _JsSpeechRecognitionEvent._(JSObject _) implements JSObject {
  external _JsSpeechRecognitionResultList get results;
  external int get resultIndex;
}

@JS()
extension type _JsSpeechRecognitionResultList._(JSObject _) implements JSObject {
  external int get length;
  @JS('item')
  external _JsSpeechRecognitionResult item(int index);
}

extension on _JsSpeechRecognitionResultList {
  _JsSpeechRecognitionResult operator [](int index) => item(index);
}

@JS()
extension type _JsSpeechRecognitionResult._(JSObject _) implements JSObject {
  external bool get isFinal;
  external int get length;
  @JS('item')
  external _JsSpeechRecognitionAlternative item(int index);
}

extension on _JsSpeechRecognitionResult {
  _JsSpeechRecognitionAlternative operator [](int index) => item(index);
}

@JS()
extension type _JsSpeechRecognitionResult2._(JSObject _) implements JSObject {
  @JS('isFinal')
  external JSBoolean get isFinalJS;
}

@JS()
extension type _JsSpeechRecognitionAlternative._(JSObject _) implements JSObject {
  external String get transcript;
  external double get confidence;
}

@JS()
extension type _JsSpeechRecognitionErrorEvent._(JSObject _) implements JSObject {
  external String get error;
  external String get message;
}

/// A speech recognition result with text and finality flag.
class SpeechResult {
  final String text;
  final bool isFinal;
  SpeechResult({required this.text, required this.isFinal});
}

/// Service wrapping the browser's Web Speech API for real-time transcription.
/// Emits a stream of [SpeechResult] with interim (partial) and final results.
class SpeechRecognitionService {
  _JsSpeechRecognition? _recognition;
  bool _isListening = false;
  int _lastFinalIndex = 0;

  /// Check if the Web Speech API is available in this browser.
  /// Tries to instantiate the recognition object — if it throws, it's unsupported.
  static bool get isSupported {
    try {
      _JsSpeechRecognition();
      return true;
    } catch (_) {
      return false;
    }
  }

  final StreamController<SpeechResult> _resultController =
      StreamController<SpeechResult>.broadcast();

  /// Stream of recognition results (both interim and final).
  Stream<SpeechResult> get resultStream => _resultController.stream;

  /// Whether recognition is currently active.
  bool get isListening => _isListening;

  /// Start speech recognition.
  /// Returns an error message on failure, null on success.
  String? start({String lang = 'en-US'}) {
    try {
      _recognition = _JsSpeechRecognition();
    } catch (_) {
      return 'Speech recognition is not supported in this browser. Please use Chrome.';
    }

    _recognition!.continuous = true;
    _recognition!.interimResults = true;
    _recognition!.lang = lang;
    _lastFinalIndex = 0;

    _recognition!.onresult = ((JSObject event) {
      _handleResult(event as _JsSpeechRecognitionEvent);
    }).toJS;

    _recognition!.onerror = ((JSObject event) {
      final errorEvent = event as _JsSpeechRecognitionErrorEvent;
      final error = errorEvent.error;
      print('[SpeechRecognition] error: $error');
      // 'no-speech' and 'aborted' are non-fatal; Chrome auto-restarts via onend
      if (error == 'network') {
        _resultController.addError('Network error: speech recognition requires internet.');
      }
    }).toJS;

    _recognition!.onend = ((JSObject event) {
      print('[SpeechRecognition] ended, _isListening=$_isListening');
      if (_isListening) {
        // Chrome stops after silence even in continuous mode — restart
        _lastFinalIndex = 0;
        try {
          _recognition!.start();
          print('[SpeechRecognition] auto-restarted');
        } catch (e) {
          print('[SpeechRecognition] auto-restart failed: $e');
        }
      }
    }).toJS;

    try {
      _recognition!.start();
      _isListening = true;
      print('[SpeechRecognition] started');
      return null;
    } catch (e) {
      return 'Failed to start speech recognition: $e';
    }
  }

  /// Stop speech recognition.
  void stop() {
    _isListening = false;
    if (_recognition != null) {
      try {
        _recognition!.stop();
      } catch (_) {}
      _recognition = null;
    }
    _lastFinalIndex = 0;
  }

  void _handleResult(_JsSpeechRecognitionEvent event) {
    final results = event.results;
    final length = results.length;

    // Emit newly finalized results
    for (var i = _lastFinalIndex; i < length; i++) {
      final result = results[i];
      // Use the JS-level isFinal check to avoid any type issues
      final isFinal = (result as _JsSpeechRecognitionResult2).isFinalJS.toDart;
      final transcript = result[0].transcript;

      if (isFinal) {
        _resultController.add(SpeechResult(text: transcript.trim(), isFinal: true));
        _lastFinalIndex = i + 1;
      }
    }

    // Emit current interim text (everything after last final)
    final interimBuffer = StringBuffer();
    for (var i = _lastFinalIndex; i < length; i++) {
      interimBuffer.write(results[i][0].transcript);
    }
    final interim = interimBuffer.toString().trim();
    if (interim.isNotEmpty) {
      _resultController.add(SpeechResult(text: interim, isFinal: false));
    }
  }

  void dispose() {
    stop();
    _resultController.close();
  }
}
