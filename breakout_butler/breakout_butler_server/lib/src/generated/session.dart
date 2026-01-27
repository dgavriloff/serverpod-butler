/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import 'room.dart' as _i2;
import 'transcript_chunk.dart' as _i3;
import 'package:breakout_butler_server/src/generated/protocol.dart' as _i4;

/// A classroom session created by a professor
abstract class ClassSession
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ClassSession._({
    this.id,
    required this.name,
    required this.roomCount,
    required this.createdAt,
    this.rooms,
    this.transcriptChunks,
  });

  factory ClassSession({
    int? id,
    required String name,
    required int roomCount,
    required DateTime createdAt,
    List<_i2.Room>? rooms,
    List<_i3.TranscriptChunk>? transcriptChunks,
  }) = _ClassSessionImpl;

  factory ClassSession.fromJson(Map<String, dynamic> jsonSerialization) {
    return ClassSession(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      roomCount: jsonSerialization['roomCount'] as int,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      rooms: jsonSerialization['rooms'] == null
          ? null
          : _i4.Protocol().deserialize<List<_i2.Room>>(
              jsonSerialization['rooms'],
            ),
      transcriptChunks: jsonSerialization['transcriptChunks'] == null
          ? null
          : _i4.Protocol().deserialize<List<_i3.TranscriptChunk>>(
              jsonSerialization['transcriptChunks'],
            ),
    );
  }

  static final t = ClassSessionTable();

  static const db = ClassSessionRepository._();

  @override
  int? id;

  /// Session name (e.g., "Milgram Discussion")
  String name;

  /// Number of breakout rooms
  int roomCount;

  /// When the session was created
  DateTime createdAt;

  /// Rooms belonging to this session
  List<_i2.Room>? rooms;

  /// Transcript chunks from this session
  List<_i3.TranscriptChunk>? transcriptChunks;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ClassSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ClassSession copyWith({
    int? id,
    String? name,
    int? roomCount,
    DateTime? createdAt,
    List<_i2.Room>? rooms,
    List<_i3.TranscriptChunk>? transcriptChunks,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ClassSession',
      if (id != null) 'id': id,
      'name': name,
      'roomCount': roomCount,
      'createdAt': createdAt.toJson(),
      if (rooms != null) 'rooms': rooms?.toJson(valueToJson: (v) => v.toJson()),
      if (transcriptChunks != null)
        'transcriptChunks': transcriptChunks?.toJson(
          valueToJson: (v) => v.toJson(),
        ),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ClassSession',
      if (id != null) 'id': id,
      'name': name,
      'roomCount': roomCount,
      'createdAt': createdAt.toJson(),
      if (rooms != null)
        'rooms': rooms?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (transcriptChunks != null)
        'transcriptChunks': transcriptChunks?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
    };
  }

  static ClassSessionInclude include({
    _i2.RoomIncludeList? rooms,
    _i3.TranscriptChunkIncludeList? transcriptChunks,
  }) {
    return ClassSessionInclude._(
      rooms: rooms,
      transcriptChunks: transcriptChunks,
    );
  }

  static ClassSessionIncludeList includeList({
    _i1.WhereExpressionBuilder<ClassSessionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ClassSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ClassSessionTable>? orderByList,
    ClassSessionInclude? include,
  }) {
    return ClassSessionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ClassSession.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ClassSession.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ClassSessionImpl extends ClassSession {
  _ClassSessionImpl({
    int? id,
    required String name,
    required int roomCount,
    required DateTime createdAt,
    List<_i2.Room>? rooms,
    List<_i3.TranscriptChunk>? transcriptChunks,
  }) : super._(
         id: id,
         name: name,
         roomCount: roomCount,
         createdAt: createdAt,
         rooms: rooms,
         transcriptChunks: transcriptChunks,
       );

  /// Returns a shallow copy of this [ClassSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ClassSession copyWith({
    Object? id = _Undefined,
    String? name,
    int? roomCount,
    DateTime? createdAt,
    Object? rooms = _Undefined,
    Object? transcriptChunks = _Undefined,
  }) {
    return ClassSession(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      roomCount: roomCount ?? this.roomCount,
      createdAt: createdAt ?? this.createdAt,
      rooms: rooms is List<_i2.Room>?
          ? rooms
          : this.rooms?.map((e0) => e0.copyWith()).toList(),
      transcriptChunks: transcriptChunks is List<_i3.TranscriptChunk>?
          ? transcriptChunks
          : this.transcriptChunks?.map((e0) => e0.copyWith()).toList(),
    );
  }
}

class ClassSessionUpdateTable extends _i1.UpdateTable<ClassSessionTable> {
  ClassSessionUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<int, int> roomCount(int value) => _i1.ColumnValue(
    table.roomCount,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class ClassSessionTable extends _i1.Table<int?> {
  ClassSessionTable({super.tableRelation}) : super(tableName: 'class_session') {
    updateTable = ClassSessionUpdateTable(this);
    name = _i1.ColumnString(
      'name',
      this,
    );
    roomCount = _i1.ColumnInt(
      'roomCount',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final ClassSessionUpdateTable updateTable;

  /// Session name (e.g., "Milgram Discussion")
  late final _i1.ColumnString name;

  /// Number of breakout rooms
  late final _i1.ColumnInt roomCount;

  /// When the session was created
  late final _i1.ColumnDateTime createdAt;

  /// Rooms belonging to this session
  _i2.RoomTable? ___rooms;

  /// Rooms belonging to this session
  _i1.ManyRelation<_i2.RoomTable>? _rooms;

  /// Transcript chunks from this session
  _i3.TranscriptChunkTable? ___transcriptChunks;

  /// Transcript chunks from this session
  _i1.ManyRelation<_i3.TranscriptChunkTable>? _transcriptChunks;

  _i2.RoomTable get __rooms {
    if (___rooms != null) return ___rooms!;
    ___rooms = _i1.createRelationTable(
      relationFieldName: '__rooms',
      field: ClassSession.t.id,
      foreignField: _i2.Room.t.sessionId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.RoomTable(tableRelation: foreignTableRelation),
    );
    return ___rooms!;
  }

  _i3.TranscriptChunkTable get __transcriptChunks {
    if (___transcriptChunks != null) return ___transcriptChunks!;
    ___transcriptChunks = _i1.createRelationTable(
      relationFieldName: '__transcriptChunks',
      field: ClassSession.t.id,
      foreignField: _i3.TranscriptChunk.t.sessionId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i3.TranscriptChunkTable(tableRelation: foreignTableRelation),
    );
    return ___transcriptChunks!;
  }

  _i1.ManyRelation<_i2.RoomTable> get rooms {
    if (_rooms != null) return _rooms!;
    var relationTable = _i1.createRelationTable(
      relationFieldName: 'rooms',
      field: ClassSession.t.id,
      foreignField: _i2.Room.t.sessionId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.RoomTable(tableRelation: foreignTableRelation),
    );
    _rooms = _i1.ManyRelation<_i2.RoomTable>(
      tableWithRelations: relationTable,
      table: _i2.RoomTable(
        tableRelation: relationTable.tableRelation!.lastRelation,
      ),
    );
    return _rooms!;
  }

  _i1.ManyRelation<_i3.TranscriptChunkTable> get transcriptChunks {
    if (_transcriptChunks != null) return _transcriptChunks!;
    var relationTable = _i1.createRelationTable(
      relationFieldName: 'transcriptChunks',
      field: ClassSession.t.id,
      foreignField: _i3.TranscriptChunk.t.sessionId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i3.TranscriptChunkTable(tableRelation: foreignTableRelation),
    );
    _transcriptChunks = _i1.ManyRelation<_i3.TranscriptChunkTable>(
      tableWithRelations: relationTable,
      table: _i3.TranscriptChunkTable(
        tableRelation: relationTable.tableRelation!.lastRelation,
      ),
    );
    return _transcriptChunks!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    roomCount,
    createdAt,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'rooms') {
      return __rooms;
    }
    if (relationField == 'transcriptChunks') {
      return __transcriptChunks;
    }
    return null;
  }
}

class ClassSessionInclude extends _i1.IncludeObject {
  ClassSessionInclude._({
    _i2.RoomIncludeList? rooms,
    _i3.TranscriptChunkIncludeList? transcriptChunks,
  }) {
    _rooms = rooms;
    _transcriptChunks = transcriptChunks;
  }

  _i2.RoomIncludeList? _rooms;

  _i3.TranscriptChunkIncludeList? _transcriptChunks;

  @override
  Map<String, _i1.Include?> get includes => {
    'rooms': _rooms,
    'transcriptChunks': _transcriptChunks,
  };

  @override
  _i1.Table<int?> get table => ClassSession.t;
}

class ClassSessionIncludeList extends _i1.IncludeList {
  ClassSessionIncludeList._({
    _i1.WhereExpressionBuilder<ClassSessionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ClassSession.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ClassSession.t;
}

class ClassSessionRepository {
  const ClassSessionRepository._();

  final attach = const ClassSessionAttachRepository._();

  final attachRow = const ClassSessionAttachRowRepository._();

  /// Returns a list of [ClassSession]s matching the given query parameters.
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
  Future<List<ClassSession>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ClassSessionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ClassSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ClassSessionTable>? orderByList,
    _i1.Transaction? transaction,
    ClassSessionInclude? include,
  }) async {
    return session.db.find<ClassSession>(
      where: where?.call(ClassSession.t),
      orderBy: orderBy?.call(ClassSession.t),
      orderByList: orderByList?.call(ClassSession.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Returns the first matching [ClassSession] matching the given query parameters.
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
  Future<ClassSession?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ClassSessionTable>? where,
    int? offset,
    _i1.OrderByBuilder<ClassSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ClassSessionTable>? orderByList,
    _i1.Transaction? transaction,
    ClassSessionInclude? include,
  }) async {
    return session.db.findFirstRow<ClassSession>(
      where: where?.call(ClassSession.t),
      orderBy: orderBy?.call(ClassSession.t),
      orderByList: orderByList?.call(ClassSession.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Finds a single [ClassSession] by its [id] or null if no such row exists.
  Future<ClassSession?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    ClassSessionInclude? include,
  }) async {
    return session.db.findById<ClassSession>(
      id,
      transaction: transaction,
      include: include,
    );
  }

  /// Inserts all [ClassSession]s in the list and returns the inserted rows.
  ///
  /// The returned [ClassSession]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ClassSession>> insert(
    _i1.Session session,
    List<ClassSession> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ClassSession>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ClassSession] and returns the inserted row.
  ///
  /// The returned [ClassSession] will have its `id` field set.
  Future<ClassSession> insertRow(
    _i1.Session session,
    ClassSession row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ClassSession>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ClassSession]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ClassSession>> update(
    _i1.Session session,
    List<ClassSession> rows, {
    _i1.ColumnSelections<ClassSessionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ClassSession>(
      rows,
      columns: columns?.call(ClassSession.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ClassSession]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ClassSession> updateRow(
    _i1.Session session,
    ClassSession row, {
    _i1.ColumnSelections<ClassSessionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ClassSession>(
      row,
      columns: columns?.call(ClassSession.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ClassSession] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ClassSession?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<ClassSessionUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ClassSession>(
      id,
      columnValues: columnValues(ClassSession.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ClassSession]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ClassSession>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<ClassSessionUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ClassSessionTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ClassSessionTable>? orderBy,
    _i1.OrderByListBuilder<ClassSessionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ClassSession>(
      columnValues: columnValues(ClassSession.t.updateTable),
      where: where(ClassSession.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ClassSession.t),
      orderByList: orderByList?.call(ClassSession.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ClassSession]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ClassSession>> delete(
    _i1.Session session,
    List<ClassSession> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ClassSession>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ClassSession].
  Future<ClassSession> deleteRow(
    _i1.Session session,
    ClassSession row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ClassSession>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ClassSession>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ClassSessionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ClassSession>(
      where: where(ClassSession.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ClassSessionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ClassSession>(
      where: where?.call(ClassSession.t),
      limit: limit,
      transaction: transaction,
    );
  }
}

class ClassSessionAttachRepository {
  const ClassSessionAttachRepository._();

  /// Creates a relation between this [ClassSession] and the given [Room]s
  /// by setting each [Room]'s foreign key `sessionId` to refer to this [ClassSession].
  Future<void> rooms(
    _i1.Session session,
    ClassSession classSession,
    List<_i2.Room> room, {
    _i1.Transaction? transaction,
  }) async {
    if (room.any((e) => e.id == null)) {
      throw ArgumentError.notNull('room.id');
    }
    if (classSession.id == null) {
      throw ArgumentError.notNull('classSession.id');
    }

    var $room = room
        .map((e) => e.copyWith(sessionId: classSession.id))
        .toList();
    await session.db.update<_i2.Room>(
      $room,
      columns: [_i2.Room.t.sessionId],
      transaction: transaction,
    );
  }

  /// Creates a relation between this [ClassSession] and the given [TranscriptChunk]s
  /// by setting each [TranscriptChunk]'s foreign key `sessionId` to refer to this [ClassSession].
  Future<void> transcriptChunks(
    _i1.Session session,
    ClassSession classSession,
    List<_i3.TranscriptChunk> transcriptChunk, {
    _i1.Transaction? transaction,
  }) async {
    if (transcriptChunk.any((e) => e.id == null)) {
      throw ArgumentError.notNull('transcriptChunk.id');
    }
    if (classSession.id == null) {
      throw ArgumentError.notNull('classSession.id');
    }

    var $transcriptChunk = transcriptChunk
        .map((e) => e.copyWith(sessionId: classSession.id))
        .toList();
    await session.db.update<_i3.TranscriptChunk>(
      $transcriptChunk,
      columns: [_i3.TranscriptChunk.t.sessionId],
      transaction: transaction,
    );
  }
}

class ClassSessionAttachRowRepository {
  const ClassSessionAttachRowRepository._();

  /// Creates a relation between this [ClassSession] and the given [Room]
  /// by setting the [Room]'s foreign key `sessionId` to refer to this [ClassSession].
  Future<void> rooms(
    _i1.Session session,
    ClassSession classSession,
    _i2.Room room, {
    _i1.Transaction? transaction,
  }) async {
    if (room.id == null) {
      throw ArgumentError.notNull('room.id');
    }
    if (classSession.id == null) {
      throw ArgumentError.notNull('classSession.id');
    }

    var $room = room.copyWith(sessionId: classSession.id);
    await session.db.updateRow<_i2.Room>(
      $room,
      columns: [_i2.Room.t.sessionId],
      transaction: transaction,
    );
  }

  /// Creates a relation between this [ClassSession] and the given [TranscriptChunk]
  /// by setting the [TranscriptChunk]'s foreign key `sessionId` to refer to this [ClassSession].
  Future<void> transcriptChunks(
    _i1.Session session,
    ClassSession classSession,
    _i3.TranscriptChunk transcriptChunk, {
    _i1.Transaction? transaction,
  }) async {
    if (transcriptChunk.id == null) {
      throw ArgumentError.notNull('transcriptChunk.id');
    }
    if (classSession.id == null) {
      throw ArgumentError.notNull('classSession.id');
    }

    var $transcriptChunk = transcriptChunk.copyWith(sessionId: classSession.id);
    await session.db.updateRow<_i3.TranscriptChunk>(
      $transcriptChunk,
      columns: [_i3.TranscriptChunk.t.sessionId],
      transaction: transaction,
    );
  }
}
