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
import 'package:serverpod/serverpod.dart' as _i1;

/// An active/live session with its URL tag
abstract class LiveSession
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  LiveSession._({
    this.id,
    required this.sessionId,
    required this.urlTag,
    required this.isActive,
    required this.transcript,
    required this.startedAt,
    this.expiresAt,
    this.creatorToken,
  });

  factory LiveSession({
    int? id,
    required int sessionId,
    required String urlTag,
    required bool isActive,
    required String transcript,
    required DateTime startedAt,
    DateTime? expiresAt,
    String? creatorToken,
  }) = _LiveSessionImpl;

  factory LiveSession.fromJson(Map<String, dynamic> jsonSerialization) {
    return LiveSession(
      id: jsonSerialization['id'] as int?,
      sessionId: jsonSerialization['sessionId'] as int,
      urlTag: jsonSerialization['urlTag'] as String,
      isActive: jsonSerialization['isActive'] as bool,
      transcript: jsonSerialization['transcript'] as String,
      startedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['startedAt'],
      ),
      expiresAt: jsonSerialization['expiresAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['expiresAt']),
      creatorToken: jsonSerialization['creatorToken'] as String?,
    );
  }

  static final t = LiveSessionTable();

  static const db = LiveSessionRepository._();

  @override
  int? id;

  /// The persistent session this live session refers to
  int sessionId;

  /// The URL tag set by professor (e.g., "psych101")
  String urlTag;

  /// Whether the session is currently active
  bool isActive;

  /// Full accumulated transcript from butler
  String transcript;

  /// When this live session was started
  DateTime startedAt;

  /// When this live session expires/ended
  DateTime? expiresAt;

  /// Secret token for creator/professor access to the dashboard
  String? creatorToken;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [LiveSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  LiveSession copyWith({
    int? id,
    int? sessionId,
    String? urlTag,
    bool? isActive,
    String? transcript,
    DateTime? startedAt,
    DateTime? expiresAt,
    String? creatorToken,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LiveSession',
      if (id != null) 'id': id,
      'sessionId': sessionId,
      'urlTag': urlTag,
      'isActive': isActive,
      'transcript': transcript,
      'startedAt': startedAt.toJson(),
      if (expiresAt != null) 'expiresAt': expiresAt?.toJson(),
      if (creatorToken != null) 'creatorToken': creatorToken,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LiveSession',
      if (id != null) 'id': id,
      'sessionId': sessionId,
      'urlTag': urlTag,
      'isActive': isActive,
      'transcript': transcript,
      'startedAt': startedAt.toJson(),
      if (expiresAt != null) 'expiresAt': expiresAt?.toJson(),
      if (creatorToken != null) 'creatorToken': creatorToken,
    };
  }

  static LiveSessionInclude include() {
    return LiveSessionInclude._();
  }

  static LiveSessionIncludeList includeList({
    _i1.WhereExpressionBuilder<LiveSessionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<LiveSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<LiveSessionTable>? orderByList,
    LiveSessionInclude? include,
  }) {
    return LiveSessionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LiveSession.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(LiveSession.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LiveSessionImpl extends LiveSession {
  _LiveSessionImpl({
    int? id,
    required int sessionId,
    required String urlTag,
    required bool isActive,
    required String transcript,
    required DateTime startedAt,
    DateTime? expiresAt,
    String? creatorToken,
  }) : super._(
         id: id,
         sessionId: sessionId,
         urlTag: urlTag,
         isActive: isActive,
         transcript: transcript,
         startedAt: startedAt,
         expiresAt: expiresAt,
         creatorToken: creatorToken,
       );

  /// Returns a shallow copy of this [LiveSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  LiveSession copyWith({
    Object? id = _Undefined,
    int? sessionId,
    String? urlTag,
    bool? isActive,
    String? transcript,
    DateTime? startedAt,
    Object? expiresAt = _Undefined,
    Object? creatorToken = _Undefined,
  }) {
    return LiveSession(
      id: id is int? ? id : this.id,
      sessionId: sessionId ?? this.sessionId,
      urlTag: urlTag ?? this.urlTag,
      isActive: isActive ?? this.isActive,
      transcript: transcript ?? this.transcript,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt is DateTime? ? expiresAt : this.expiresAt,
      creatorToken: creatorToken is String? ? creatorToken : this.creatorToken,
    );
  }
}

class LiveSessionUpdateTable extends _i1.UpdateTable<LiveSessionTable> {
  LiveSessionUpdateTable(super.table);

  _i1.ColumnValue<int, int> sessionId(int value) => _i1.ColumnValue(
    table.sessionId,
    value,
  );

  _i1.ColumnValue<String, String> urlTag(String value) => _i1.ColumnValue(
    table.urlTag,
    value,
  );

  _i1.ColumnValue<bool, bool> isActive(bool value) => _i1.ColumnValue(
    table.isActive,
    value,
  );

  _i1.ColumnValue<String, String> transcript(String value) => _i1.ColumnValue(
    table.transcript,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> startedAt(DateTime value) =>
      _i1.ColumnValue(
        table.startedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> expiresAt(DateTime? value) =>
      _i1.ColumnValue(
        table.expiresAt,
        value,
      );

  _i1.ColumnValue<String, String> creatorToken(String? value) =>
      _i1.ColumnValue(
        table.creatorToken,
        value,
      );
}

class LiveSessionTable extends _i1.Table<int?> {
  LiveSessionTable({super.tableRelation}) : super(tableName: 'live_session') {
    updateTable = LiveSessionUpdateTable(this);
    sessionId = _i1.ColumnInt(
      'sessionId',
      this,
    );
    urlTag = _i1.ColumnString(
      'urlTag',
      this,
    );
    isActive = _i1.ColumnBool(
      'isActive',
      this,
    );
    transcript = _i1.ColumnString(
      'transcript',
      this,
    );
    startedAt = _i1.ColumnDateTime(
      'startedAt',
      this,
    );
    expiresAt = _i1.ColumnDateTime(
      'expiresAt',
      this,
    );
    creatorToken = _i1.ColumnString(
      'creatorToken',
      this,
    );
  }

  late final LiveSessionUpdateTable updateTable;

  /// The persistent session this live session refers to
  late final _i1.ColumnInt sessionId;

  /// The URL tag set by professor (e.g., "psych101")
  late final _i1.ColumnString urlTag;

  /// Whether the session is currently active
  late final _i1.ColumnBool isActive;

  /// Full accumulated transcript from butler
  late final _i1.ColumnString transcript;

  /// When this live session was started
  late final _i1.ColumnDateTime startedAt;

  /// When this live session expires/ended
  late final _i1.ColumnDateTime expiresAt;

  /// Secret token for creator/professor access to the dashboard
  late final _i1.ColumnString creatorToken;

  @override
  List<_i1.Column> get columns => [
    id,
    sessionId,
    urlTag,
    isActive,
    transcript,
    startedAt,
    expiresAt,
    creatorToken,
  ];
}

class LiveSessionInclude extends _i1.IncludeObject {
  LiveSessionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => LiveSession.t;
}

class LiveSessionIncludeList extends _i1.IncludeList {
  LiveSessionIncludeList._({
    _i1.WhereExpressionBuilder<LiveSessionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(LiveSession.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => LiveSession.t;
}

class LiveSessionRepository {
  const LiveSessionRepository._();

  /// Returns a list of [LiveSession]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<LiveSession>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<LiveSessionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<LiveSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<LiveSessionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<LiveSession>(
      where: where?.call(LiveSession.t),
      orderBy: orderBy?.call(LiveSession.t),
      orderByList: orderByList?.call(LiveSession.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [LiveSession] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<LiveSession?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<LiveSessionTable>? where,
    int? offset,
    _i1.OrderByBuilder<LiveSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<LiveSessionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<LiveSession>(
      where: where?.call(LiveSession.t),
      orderBy: orderBy?.call(LiveSession.t),
      orderByList: orderByList?.call(LiveSession.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [LiveSession] by its [id] or null if no such row exists.
  Future<LiveSession?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<LiveSession>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [LiveSession]s in the list and returns the inserted rows.
  ///
  /// The returned [LiveSession]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<LiveSession>> insert(
    _i1.Session session,
    List<LiveSession> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<LiveSession>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [LiveSession] and returns the inserted row.
  ///
  /// The returned [LiveSession] will have its `id` field set.
  Future<LiveSession> insertRow(
    _i1.Session session,
    LiveSession row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<LiveSession>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [LiveSession]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<LiveSession>> update(
    _i1.Session session,
    List<LiveSession> rows, {
    _i1.ColumnSelections<LiveSessionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<LiveSession>(
      rows,
      columns: columns?.call(LiveSession.t),
      transaction: transaction,
    );
  }

  /// Updates a single [LiveSession]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<LiveSession> updateRow(
    _i1.Session session,
    LiveSession row, {
    _i1.ColumnSelections<LiveSessionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<LiveSession>(
      row,
      columns: columns?.call(LiveSession.t),
      transaction: transaction,
    );
  }

  /// Updates a single [LiveSession] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<LiveSession?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<LiveSessionUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<LiveSession>(
      id,
      columnValues: columnValues(LiveSession.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [LiveSession]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<LiveSession>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<LiveSessionUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<LiveSessionTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<LiveSessionTable>? orderBy,
    _i1.OrderByListBuilder<LiveSessionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<LiveSession>(
      columnValues: columnValues(LiveSession.t.updateTable),
      where: where(LiveSession.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LiveSession.t),
      orderByList: orderByList?.call(LiveSession.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [LiveSession]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<LiveSession>> delete(
    _i1.Session session,
    List<LiveSession> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<LiveSession>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [LiveSession].
  Future<LiveSession> deleteRow(
    _i1.Session session,
    LiveSession row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<LiveSession>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<LiveSession>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<LiveSessionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<LiveSession>(
      where: where(LiveSession.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<LiveSessionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<LiveSession>(
      where: where?.call(LiveSession.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
