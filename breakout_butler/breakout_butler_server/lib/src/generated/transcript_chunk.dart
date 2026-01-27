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

/// A chunk of transcribed audio from the professor
abstract class TranscriptChunk
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  TranscriptChunk._({
    this.id,
    required this.sessionId,
    required this.timestamp,
    required this.text,
  });

  factory TranscriptChunk({
    int? id,
    required int sessionId,
    required DateTime timestamp,
    required String text,
  }) = _TranscriptChunkImpl;

  factory TranscriptChunk.fromJson(Map<String, dynamic> jsonSerialization) {
    return TranscriptChunk(
      id: jsonSerialization['id'] as int?,
      sessionId: jsonSerialization['sessionId'] as int,
      timestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
      text: jsonSerialization['text'] as String,
    );
  }

  static final t = TranscriptChunkTable();

  static const db = TranscriptChunkRepository._();

  @override
  int? id;

  /// The session this transcript belongs to
  int sessionId;

  /// When this chunk was transcribed
  DateTime timestamp;

  /// The transcribed text
  String text;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [TranscriptChunk]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TranscriptChunk copyWith({
    int? id,
    int? sessionId,
    DateTime? timestamp,
    String? text,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TranscriptChunk',
      if (id != null) 'id': id,
      'sessionId': sessionId,
      'timestamp': timestamp.toJson(),
      'text': text,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TranscriptChunk',
      if (id != null) 'id': id,
      'sessionId': sessionId,
      'timestamp': timestamp.toJson(),
      'text': text,
    };
  }

  static TranscriptChunkInclude include() {
    return TranscriptChunkInclude._();
  }

  static TranscriptChunkIncludeList includeList({
    _i1.WhereExpressionBuilder<TranscriptChunkTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TranscriptChunkTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TranscriptChunkTable>? orderByList,
    TranscriptChunkInclude? include,
  }) {
    return TranscriptChunkIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TranscriptChunk.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(TranscriptChunk.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TranscriptChunkImpl extends TranscriptChunk {
  _TranscriptChunkImpl({
    int? id,
    required int sessionId,
    required DateTime timestamp,
    required String text,
  }) : super._(
         id: id,
         sessionId: sessionId,
         timestamp: timestamp,
         text: text,
       );

  /// Returns a shallow copy of this [TranscriptChunk]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TranscriptChunk copyWith({
    Object? id = _Undefined,
    int? sessionId,
    DateTime? timestamp,
    String? text,
  }) {
    return TranscriptChunk(
      id: id is int? ? id : this.id,
      sessionId: sessionId ?? this.sessionId,
      timestamp: timestamp ?? this.timestamp,
      text: text ?? this.text,
    );
  }
}

class TranscriptChunkUpdateTable extends _i1.UpdateTable<TranscriptChunkTable> {
  TranscriptChunkUpdateTable(super.table);

  _i1.ColumnValue<int, int> sessionId(int value) => _i1.ColumnValue(
    table.sessionId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> timestamp(DateTime value) =>
      _i1.ColumnValue(
        table.timestamp,
        value,
      );

  _i1.ColumnValue<String, String> text(String value) => _i1.ColumnValue(
    table.text,
    value,
  );
}

class TranscriptChunkTable extends _i1.Table<int?> {
  TranscriptChunkTable({super.tableRelation})
    : super(tableName: 'transcript_chunk') {
    updateTable = TranscriptChunkUpdateTable(this);
    sessionId = _i1.ColumnInt(
      'sessionId',
      this,
    );
    timestamp = _i1.ColumnDateTime(
      'timestamp',
      this,
    );
    text = _i1.ColumnString(
      'text',
      this,
    );
  }

  late final TranscriptChunkUpdateTable updateTable;

  /// The session this transcript belongs to
  late final _i1.ColumnInt sessionId;

  /// When this chunk was transcribed
  late final _i1.ColumnDateTime timestamp;

  /// The transcribed text
  late final _i1.ColumnString text;

  @override
  List<_i1.Column> get columns => [
    id,
    sessionId,
    timestamp,
    text,
  ];
}

class TranscriptChunkInclude extends _i1.IncludeObject {
  TranscriptChunkInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => TranscriptChunk.t;
}

class TranscriptChunkIncludeList extends _i1.IncludeList {
  TranscriptChunkIncludeList._({
    _i1.WhereExpressionBuilder<TranscriptChunkTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TranscriptChunk.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => TranscriptChunk.t;
}

class TranscriptChunkRepository {
  const TranscriptChunkRepository._();

  /// Returns a list of [TranscriptChunk]s matching the given query parameters.
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
  Future<List<TranscriptChunk>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TranscriptChunkTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TranscriptChunkTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TranscriptChunkTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<TranscriptChunk>(
      where: where?.call(TranscriptChunk.t),
      orderBy: orderBy?.call(TranscriptChunk.t),
      orderByList: orderByList?.call(TranscriptChunk.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [TranscriptChunk] matching the given query parameters.
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
  Future<TranscriptChunk?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TranscriptChunkTable>? where,
    int? offset,
    _i1.OrderByBuilder<TranscriptChunkTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TranscriptChunkTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<TranscriptChunk>(
      where: where?.call(TranscriptChunk.t),
      orderBy: orderBy?.call(TranscriptChunk.t),
      orderByList: orderByList?.call(TranscriptChunk.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [TranscriptChunk] by its [id] or null if no such row exists.
  Future<TranscriptChunk?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<TranscriptChunk>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [TranscriptChunk]s in the list and returns the inserted rows.
  ///
  /// The returned [TranscriptChunk]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<TranscriptChunk>> insert(
    _i1.Session session,
    List<TranscriptChunk> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<TranscriptChunk>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [TranscriptChunk] and returns the inserted row.
  ///
  /// The returned [TranscriptChunk] will have its `id` field set.
  Future<TranscriptChunk> insertRow(
    _i1.Session session,
    TranscriptChunk row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<TranscriptChunk>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [TranscriptChunk]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<TranscriptChunk>> update(
    _i1.Session session,
    List<TranscriptChunk> rows, {
    _i1.ColumnSelections<TranscriptChunkTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<TranscriptChunk>(
      rows,
      columns: columns?.call(TranscriptChunk.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TranscriptChunk]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TranscriptChunk> updateRow(
    _i1.Session session,
    TranscriptChunk row, {
    _i1.ColumnSelections<TranscriptChunkTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<TranscriptChunk>(
      row,
      columns: columns?.call(TranscriptChunk.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TranscriptChunk] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TranscriptChunk?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<TranscriptChunkUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<TranscriptChunk>(
      id,
      columnValues: columnValues(TranscriptChunk.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TranscriptChunk]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<TranscriptChunk>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<TranscriptChunkUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<TranscriptChunkTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TranscriptChunkTable>? orderBy,
    _i1.OrderByListBuilder<TranscriptChunkTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<TranscriptChunk>(
      columnValues: columnValues(TranscriptChunk.t.updateTable),
      where: where(TranscriptChunk.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TranscriptChunk.t),
      orderByList: orderByList?.call(TranscriptChunk.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [TranscriptChunk]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<TranscriptChunk>> delete(
    _i1.Session session,
    List<TranscriptChunk> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<TranscriptChunk>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [TranscriptChunk].
  Future<TranscriptChunk> deleteRow(
    _i1.Session session,
    TranscriptChunk row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TranscriptChunk>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<TranscriptChunk>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<TranscriptChunkTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<TranscriptChunk>(
      where: where(TranscriptChunk.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TranscriptChunkTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<TranscriptChunk>(
      where: where?.call(TranscriptChunk.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
