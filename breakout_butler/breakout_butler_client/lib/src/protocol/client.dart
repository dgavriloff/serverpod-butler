/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i1;
import 'package:serverpod_client/serverpod_client.dart' as _i2;
import 'dart:async' as _i3;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i4;
import 'package:breakout_butler_client/src/protocol/transcript_update.dart'
    as _i5;
import 'dart:typed_data' as _i6;
import 'package:breakout_butler_client/src/protocol/butler_response.dart'
    as _i7;
import 'package:breakout_butler_client/src/protocol/room.dart' as _i8;
import 'package:breakout_butler_client/src/protocol/room_update.dart' as _i9;
import 'package:breakout_butler_client/src/protocol/session.dart' as _i10;
import 'package:breakout_butler_client/src/protocol/live_session.dart' as _i11;
import 'package:breakout_butler_client/src/protocol/greetings/greeting.dart'
    as _i12;
import 'protocol.dart' as _i13;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _i1.EndpointEmailIdpBase {
  EndpointEmailIdp(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<_i4.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _i3.Future<_i2.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _i3.Future<String> verifyRegistrationCode({
    required _i2.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _i3.Future<_i4.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _i3.Future<_i2.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _i3.Future<String> verifyPasswordResetCode({
    required _i2.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _i4.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _i3.Future<_i4.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'jwtRefresh',
    'refreshAccessToken',
    {'refreshToken': refreshToken},
    authenticated: false,
  );
}

/// Endpoint for butler AI features - transcription and Q&A
/// {@category Endpoint}
class EndpointButler extends _i2.EndpointRef {
  EndpointButler(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'butler';

  /// Stream transcript updates to all connected clients
  _i3.Stream<_i5.TranscriptUpdate> transcriptStream(int sessionId) =>
      caller.callStreamingServerEndpoint<
        _i3.Stream<_i5.TranscriptUpdate>,
        _i5.TranscriptUpdate
      >(
        'butler',
        'transcriptStream',
        {'sessionId': sessionId},
        {},
      );

  /// Process audio chunk and transcribe using Gemini
  _i3.Future<String> processAudio(
    int sessionId,
    _i6.Uint8List audioData,
    String mimeType,
  ) => caller.callServerEndpoint<String>(
    'butler',
    'processAudio',
    {
      'sessionId': sessionId,
      'audioData': audioData,
      'mimeType': mimeType,
    },
  );

  /// Manually add text to transcript (useful for testing and demo)
  _i3.Future<void> addTranscriptText(
    int sessionId,
    String text,
  ) => caller.callServerEndpoint<void>(
    'butler',
    'addTranscriptText',
    {
      'sessionId': sessionId,
      'text': text,
    },
  );

  /// Ask the butler a question about the transcript - uses Gemini AI
  _i3.Future<_i7.ButlerResponse> askButler(
    int sessionId,
    String question,
  ) => caller.callServerEndpoint<_i7.ButlerResponse>(
    'butler',
    'askButler',
    {
      'sessionId': sessionId,
      'question': question,
    },
  );

  /// Get the current prompt/assignment for the session
  _i3.Future<String> getSessionPrompt(int sessionId) =>
      caller.callServerEndpoint<String>(
        'butler',
        'getSessionPrompt',
        {'sessionId': sessionId},
      );

  /// Summarize a specific room's content using Gemini
  _i3.Future<_i7.ButlerResponse> summarizeRoom(
    int sessionId,
    int roomNumber,
  ) => caller.callServerEndpoint<_i7.ButlerResponse>(
    'butler',
    'summarizeRoom',
    {
      'sessionId': sessionId,
      'roomNumber': roomNumber,
    },
  );

  /// Synthesize insights across all rooms
  _i3.Future<_i7.ButlerResponse> synthesizeAllRooms(int sessionId) =>
      caller.callServerEndpoint<_i7.ButlerResponse>(
        'butler',
        'synthesizeAllRooms',
        {'sessionId': sessionId},
      );

  /// Try to extract assignment from transcript
  _i3.Future<String?> extractAssignment(int sessionId) =>
      caller.callServerEndpoint<String?>(
        'butler',
        'extractAssignment',
        {'sessionId': sessionId},
      );
}

/// Endpoint for managing breakout room workspaces with real-time collaboration
/// {@category Endpoint}
class EndpointRoom extends _i2.EndpointRef {
  EndpointRoom(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'room';

  /// Get a specific room by session ID and room number
  _i3.Future<_i8.Room?> getRoom(
    int sessionId,
    int roomNumber,
  ) => caller.callServerEndpoint<_i8.Room?>(
    'room',
    'getRoom',
    {
      'sessionId': sessionId,
      'roomNumber': roomNumber,
    },
  );

  /// Update room content
  _i3.Future<_i8.Room> updateRoomContent(
    int sessionId,
    int roomNumber,
    String content,
  ) => caller.callServerEndpoint<_i8.Room>(
    'room',
    'updateRoomContent',
    {
      'sessionId': sessionId,
      'roomNumber': roomNumber,
      'content': content,
    },
  );

  /// Stream real-time room updates for a specific room
  _i3.Stream<_i9.RoomUpdate> roomUpdates(
    int sessionId,
    int roomNumber,
  ) => caller
      .callStreamingServerEndpoint<_i3.Stream<_i9.RoomUpdate>, _i9.RoomUpdate>(
        'room',
        'roomUpdates',
        {
          'sessionId': sessionId,
          'roomNumber': roomNumber,
        },
        {},
      );

  /// Stream updates for ALL rooms in a session (for professor dashboard)
  _i3.Stream<_i9.RoomUpdate> allRoomUpdates(int sessionId) => caller
      .callStreamingServerEndpoint<_i3.Stream<_i9.RoomUpdate>, _i9.RoomUpdate>(
        'room',
        'allRoomUpdates',
        {'sessionId': sessionId},
        {},
      );

  /// Get all rooms for a session (snapshot, not streaming)
  _i3.Future<List<_i8.Room>> getAllRooms(int sessionId) =>
      caller.callServerEndpoint<List<_i8.Room>>(
        'room',
        'getAllRooms',
        {'sessionId': sessionId},
      );
}

/// Endpoint for managing classroom sessions
/// {@category Endpoint}
class EndpointSession extends _i2.EndpointRef {
  EndpointSession(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'session';

  /// Create a new classroom session
  _i3.Future<_i10.ClassSession> createSession(
    String name,
    String prompt,
    int roomCount,
  ) => caller.callServerEndpoint<_i10.ClassSession>(
    'session',
    'createSession',
    {
      'name': name,
      'prompt': prompt,
      'roomCount': roomCount,
    },
  );

  /// Start a live session with a URL tag
  _i3.Future<_i11.LiveSession> startLiveSession(
    int sessionId,
    String urlTag,
  ) => caller.callServerEndpoint<_i11.LiveSession>(
    'session',
    'startLiveSession',
    {
      'sessionId': sessionId,
      'urlTag': urlTag,
    },
  );

  /// Get a live session by URL tag
  _i3.Future<_i11.LiveSession?> getLiveSessionByTag(String urlTag) =>
      caller.callServerEndpoint<_i11.LiveSession?>(
        'session',
        'getLiveSessionByTag',
        {'urlTag': urlTag},
      );

  /// Get session details including rooms
  _i3.Future<_i10.ClassSession?> getSession(int sessionId) =>
      caller.callServerEndpoint<_i10.ClassSession?>(
        'session',
        'getSession',
        {'sessionId': sessionId},
      );

  /// End a live session
  _i3.Future<void> endLiveSession(String urlTag) =>
      caller.callServerEndpoint<void>(
        'session',
        'endLiveSession',
        {'urlTag': urlTag},
      );

  /// Get all rooms for a session
  _i3.Future<List<_i8.Room>> getRooms(int sessionId) =>
      caller.callServerEndpoint<List<_i8.Room>>(
        'session',
        'getRooms',
        {'sessionId': sessionId},
      );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i2.EndpointRef {
  EndpointGreeting(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i3.Future<_i12.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i12.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i1.Caller(client);
    serverpod_auth_core = _i4.Caller(client);
  }

  late final _i1.Caller serverpod_auth_idp;

  late final _i4.Caller serverpod_auth_core;
}

class Client extends _i2.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i2.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i2.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i13.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    butler = EndpointButler(this);
    room = EndpointRoom(this);
    session = EndpointSession(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointButler butler;

  late final EndpointRoom room;

  late final EndpointSession session;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _i2.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'butler': butler,
    'room': room,
    'session': session,
    'greeting': greeting,
  };

  @override
  Map<String, _i2.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
