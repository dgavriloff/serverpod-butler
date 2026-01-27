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

/// A breakout room workspace
abstract class Room implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Room._({
    this.id,
    required this.sessionId,
    required this.roomNumber,
    required this.content,
    required this.updatedAt,
  });

  factory Room({
    int? id,
    required int sessionId,
    required int roomNumber,
    required String content,
    required DateTime updatedAt,
  }) = _RoomImpl;

  factory Room.fromJson(Map<String, dynamic> jsonSerialization) {
    return Room(
      id: jsonSerialization['id'] as int?,
      sessionId: jsonSerialization['sessionId'] as int,
      roomNumber: jsonSerialization['roomNumber'] as int,
      content: jsonSerialization['content'] as String,
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = RoomTable();

  static const db = RoomRepository._();

  @override
  int? id;

  /// The session this room belongs to
  int sessionId;

  /// Room number (matches Zoom breakout room number)
  int roomNumber;

  /// Collaborative text document content
  String content;

  /// Last updated timestamp
  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Room]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Room copyWith({
    int? id,
    int? sessionId,
    int? roomNumber,
    String? content,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Room',
      if (id != null) 'id': id,
      'sessionId': sessionId,
      'roomNumber': roomNumber,
      'content': content,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Room',
      if (id != null) 'id': id,
      'sessionId': sessionId,
      'roomNumber': roomNumber,
      'content': content,
      'updatedAt': updatedAt.toJson(),
    };
  }

  static RoomInclude include() {
    return RoomInclude._();
  }

  static RoomIncludeList includeList({
    _i1.WhereExpressionBuilder<RoomTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RoomTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RoomTable>? orderByList,
    RoomInclude? include,
  }) {
    return RoomIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Room.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Room.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoomImpl extends Room {
  _RoomImpl({
    int? id,
    required int sessionId,
    required int roomNumber,
    required String content,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         sessionId: sessionId,
         roomNumber: roomNumber,
         content: content,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Room]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Room copyWith({
    Object? id = _Undefined,
    int? sessionId,
    int? roomNumber,
    String? content,
    DateTime? updatedAt,
  }) {
    return Room(
      id: id is int? ? id : this.id,
      sessionId: sessionId ?? this.sessionId,
      roomNumber: roomNumber ?? this.roomNumber,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RoomUpdateTable extends _i1.UpdateTable<RoomTable> {
  RoomUpdateTable(super.table);

  _i1.ColumnValue<int, int> sessionId(int value) => _i1.ColumnValue(
    table.sessionId,
    value,
  );

  _i1.ColumnValue<int, int> roomNumber(int value) => _i1.ColumnValue(
    table.roomNumber,
    value,
  );

  _i1.ColumnValue<String, String> content(String value) => _i1.ColumnValue(
    table.content,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class RoomTable extends _i1.Table<int?> {
  RoomTable({super.tableRelation}) : super(tableName: 'room') {
    updateTable = RoomUpdateTable(this);
    sessionId = _i1.ColumnInt(
      'sessionId',
      this,
    );
    roomNumber = _i1.ColumnInt(
      'roomNumber',
      this,
    );
    content = _i1.ColumnString(
      'content',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final RoomUpdateTable updateTable;

  /// The session this room belongs to
  late final _i1.ColumnInt sessionId;

  /// Room number (matches Zoom breakout room number)
  late final _i1.ColumnInt roomNumber;

  /// Collaborative text document content
  late final _i1.ColumnString content;

  /// Last updated timestamp
  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    sessionId,
    roomNumber,
    content,
    updatedAt,
  ];
}

class RoomInclude extends _i1.IncludeObject {
  RoomInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Room.t;
}

class RoomIncludeList extends _i1.IncludeList {
  RoomIncludeList._({
    _i1.WhereExpressionBuilder<RoomTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Room.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Room.t;
}

class RoomRepository {
  const RoomRepository._();

  /// Returns a list of [Room]s matching the given query parameters.
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
  Future<List<Room>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<RoomTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RoomTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RoomTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Room>(
      where: where?.call(Room.t),
      orderBy: orderBy?.call(Room.t),
      orderByList: orderByList?.call(Room.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [Room] matching the given query parameters.
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
  Future<Room?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<RoomTable>? where,
    int? offset,
    _i1.OrderByBuilder<RoomTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RoomTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Room>(
      where: where?.call(Room.t),
      orderBy: orderBy?.call(Room.t),
      orderByList: orderByList?.call(Room.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [Room] by its [id] or null if no such row exists.
  Future<Room?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Room>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [Room]s in the list and returns the inserted rows.
  ///
  /// The returned [Room]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Room>> insert(
    _i1.Session session,
    List<Room> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Room>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Room] and returns the inserted row.
  ///
  /// The returned [Room] will have its `id` field set.
  Future<Room> insertRow(
    _i1.Session session,
    Room row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Room>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Room]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Room>> update(
    _i1.Session session,
    List<Room> rows, {
    _i1.ColumnSelections<RoomTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Room>(
      rows,
      columns: columns?.call(Room.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Room]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Room> updateRow(
    _i1.Session session,
    Room row, {
    _i1.ColumnSelections<RoomTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Room>(
      row,
      columns: columns?.call(Room.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Room] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Room?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<RoomUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Room>(
      id,
      columnValues: columnValues(Room.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Room]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Room>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<RoomUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<RoomTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RoomTable>? orderBy,
    _i1.OrderByListBuilder<RoomTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Room>(
      columnValues: columnValues(Room.t.updateTable),
      where: where(Room.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Room.t),
      orderByList: orderByList?.call(Room.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Room]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Room>> delete(
    _i1.Session session,
    List<Room> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Room>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Room].
  Future<Room> deleteRow(
    _i1.Session session,
    Room row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Room>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Room>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<RoomTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Room>(
      where: where(Room.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<RoomTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Room>(
      where: where?.call(Room.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
