// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_conversation.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocalConversationCollection on Isar {
  IsarCollection<LocalConversation> get localConversations => this.collection();
}

const LocalConversationSchema = CollectionSchema(
  name: r'LocalConversation',
  id: 6912738895845273116,
  properties: {
    r'conversationId': PropertySchema(
      id: 0,
      name: r'conversationId',
      type: IsarType.string,
    ),
    r'isTyping': PropertySchema(
      id: 1,
      name: r'isTyping',
      type: IsarType.bool,
    ),
    r'lastMessageIsOwn': PropertySchema(
      id: 2,
      name: r'lastMessageIsOwn',
      type: IsarType.bool,
    ),
    r'lastMessagePreview': PropertySchema(
      id: 3,
      name: r'lastMessagePreview',
      type: IsarType.string,
    ),
    r'lastMessageStatus': PropertySchema(
      id: 4,
      name: r'lastMessageStatus',
      type: IsarType.string,
    ),
    r'lastSyncedAt': PropertySchema(
      id: 5,
      name: r'lastSyncedAt',
      type: IsarType.dateTime,
    ),
    r'participantAvatarUrl': PropertySchema(
      id: 6,
      name: r'participantAvatarUrl',
      type: IsarType.string,
    ),
    r'participantId': PropertySchema(
      id: 7,
      name: r'participantId',
      type: IsarType.string,
    ),
    r'participantIsOnline': PropertySchema(
      id: 8,
      name: r'participantIsOnline',
      type: IsarType.bool,
    ),
    r'participantLastSeenAt': PropertySchema(
      id: 9,
      name: r'participantLastSeenAt',
      type: IsarType.dateTime,
    ),
    r'participantName': PropertySchema(
      id: 10,
      name: r'participantName',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 11,
      name: r'status',
      type: IsarType.string,
    ),
    r'unreadCount': PropertySchema(
      id: 12,
      name: r'unreadCount',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 13,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _localConversationEstimateSize,
  serialize: _localConversationSerialize,
  deserialize: _localConversationDeserialize,
  deserializeProp: _localConversationDeserializeProp,
  idName: r'id',
  indexes: {
    r'conversationId': IndexSchema(
      id: 2945908346256754300,
      name: r'conversationId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'conversationId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _localConversationGetId,
  getLinks: _localConversationGetLinks,
  attach: _localConversationAttach,
  version: '3.1.0+1',
);

int _localConversationEstimateSize(
  LocalConversation object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.conversationId.length * 3;
  bytesCount += 3 + object.lastMessagePreview.length * 3;
  bytesCount += 3 + object.lastMessageStatus.length * 3;
  {
    final value = object.participantAvatarUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.participantId.length * 3;
  bytesCount += 3 + object.participantName.length * 3;
  bytesCount += 3 + object.status.length * 3;
  return bytesCount;
}

void _localConversationSerialize(
  LocalConversation object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.conversationId);
  writer.writeBool(offsets[1], object.isTyping);
  writer.writeBool(offsets[2], object.lastMessageIsOwn);
  writer.writeString(offsets[3], object.lastMessagePreview);
  writer.writeString(offsets[4], object.lastMessageStatus);
  writer.writeDateTime(offsets[5], object.lastSyncedAt);
  writer.writeString(offsets[6], object.participantAvatarUrl);
  writer.writeString(offsets[7], object.participantId);
  writer.writeBool(offsets[8], object.participantIsOnline);
  writer.writeDateTime(offsets[9], object.participantLastSeenAt);
  writer.writeString(offsets[10], object.participantName);
  writer.writeString(offsets[11], object.status);
  writer.writeLong(offsets[12], object.unreadCount);
  writer.writeDateTime(offsets[13], object.updatedAt);
}

LocalConversation _localConversationDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalConversation();
  object.conversationId = reader.readString(offsets[0]);
  object.id = id;
  object.isTyping = reader.readBool(offsets[1]);
  object.lastMessageIsOwn = reader.readBool(offsets[2]);
  object.lastMessagePreview = reader.readString(offsets[3]);
  object.lastMessageStatus = reader.readString(offsets[4]);
  object.lastSyncedAt = reader.readDateTimeOrNull(offsets[5]);
  object.participantAvatarUrl = reader.readStringOrNull(offsets[6]);
  object.participantId = reader.readString(offsets[7]);
  object.participantIsOnline = reader.readBool(offsets[8]);
  object.participantLastSeenAt = reader.readDateTimeOrNull(offsets[9]);
  object.participantName = reader.readString(offsets[10]);
  object.status = reader.readString(offsets[11]);
  object.unreadCount = reader.readLong(offsets[12]);
  object.updatedAt = reader.readDateTime(offsets[13]);
  return object;
}

P _localConversationDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _localConversationGetId(LocalConversation object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _localConversationGetLinks(
    LocalConversation object) {
  return [];
}

void _localConversationAttach(
    IsarCollection<dynamic> col, Id id, LocalConversation object) {
  object.id = id;
}

extension LocalConversationByIndex on IsarCollection<LocalConversation> {
  Future<LocalConversation?> getByConversationId(String conversationId) {
    return getByIndex(r'conversationId', [conversationId]);
  }

  LocalConversation? getByConversationIdSync(String conversationId) {
    return getByIndexSync(r'conversationId', [conversationId]);
  }

  Future<bool> deleteByConversationId(String conversationId) {
    return deleteByIndex(r'conversationId', [conversationId]);
  }

  bool deleteByConversationIdSync(String conversationId) {
    return deleteByIndexSync(r'conversationId', [conversationId]);
  }

  Future<List<LocalConversation?>> getAllByConversationId(
      List<String> conversationIdValues) {
    final values = conversationIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'conversationId', values);
  }

  List<LocalConversation?> getAllByConversationIdSync(
      List<String> conversationIdValues) {
    final values = conversationIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'conversationId', values);
  }

  Future<int> deleteAllByConversationId(List<String> conversationIdValues) {
    final values = conversationIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'conversationId', values);
  }

  int deleteAllByConversationIdSync(List<String> conversationIdValues) {
    final values = conversationIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'conversationId', values);
  }

  Future<Id> putByConversationId(LocalConversation object) {
    return putByIndex(r'conversationId', object);
  }

  Id putByConversationIdSync(LocalConversation object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'conversationId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByConversationId(List<LocalConversation> objects) {
    return putAllByIndex(r'conversationId', objects);
  }

  List<Id> putAllByConversationIdSync(List<LocalConversation> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'conversationId', objects, saveLinks: saveLinks);
  }
}

extension LocalConversationQueryWhereSort
    on QueryBuilder<LocalConversation, LocalConversation, QWhere> {
  QueryBuilder<LocalConversation, LocalConversation, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LocalConversationQueryWhere
    on QueryBuilder<LocalConversation, LocalConversation, QWhereClause> {
  QueryBuilder<LocalConversation, LocalConversation, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterWhereClause>
      conversationIdEqualTo(String conversationId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'conversationId',
        value: [conversationId],
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterWhereClause>
      conversationIdNotEqualTo(String conversationId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId',
              lower: [],
              upper: [conversationId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId',
              lower: [conversationId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId',
              lower: [conversationId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId',
              lower: [],
              upper: [conversationId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension LocalConversationQueryFilter
    on QueryBuilder<LocalConversation, LocalConversation, QFilterCondition> {
  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      conversationIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      conversationIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      conversationIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      conversationIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'conversationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      conversationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      conversationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      conversationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      conversationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'conversationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      conversationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conversationId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      conversationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'conversationId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      isTypingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isTyping',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastMessageIsOwnEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessageIsOwn',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastMessagePreviewEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessagePreview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastMessagePreviewGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMessagePreview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastMessagePreviewLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMessagePreview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastMessagePreviewBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMessagePreview',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastMessagePreviewStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastMessagePreview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastMessagePreviewEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastMessagePreview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastMessagePreviewContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastMessagePreview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastMessagePreviewMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastMessagePreview',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastMessagePreviewIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessagePreview',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastMessagePreviewIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastMessagePreview',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastMessageStatusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessageStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastMessageStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMessageStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastMessageStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMessageStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastMessageStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMessageStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastMessageStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastMessageStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastMessageStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastMessageStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastMessageStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastMessageStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastMessageStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastMessageStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastMessageStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessageStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastMessageStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastMessageStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastSyncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSyncedAt',
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastSyncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSyncedAt',
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastSyncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastSyncedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastSyncedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      lastSyncedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantAvatarUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'participantAvatarUrl',
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantAvatarUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'participantAvatarUrl',
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantAvatarUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'participantAvatarUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantAvatarUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'participantAvatarUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantAvatarUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'participantAvatarUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantAvatarUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'participantAvatarUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantAvatarUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'participantAvatarUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantAvatarUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'participantAvatarUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantAvatarUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'participantAvatarUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantAvatarUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'participantAvatarUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantAvatarUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'participantAvatarUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantAvatarUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'participantAvatarUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'participantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'participantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'participantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'participantId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'participantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'participantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'participantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'participantId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'participantId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'participantId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantIsOnlineEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'participantIsOnline',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantLastSeenAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'participantLastSeenAt',
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantLastSeenAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'participantLastSeenAt',
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantLastSeenAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'participantLastSeenAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantLastSeenAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'participantLastSeenAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantLastSeenAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'participantLastSeenAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantLastSeenAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'participantLastSeenAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'participantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'participantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'participantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'participantName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'participantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'participantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'participantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'participantName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'participantName',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      participantNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'participantName',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      unreadCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unreadCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      unreadCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unreadCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      unreadCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unreadCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      unreadCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unreadCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LocalConversationQueryObject
    on QueryBuilder<LocalConversation, LocalConversation, QFilterCondition> {}

extension LocalConversationQueryLinks
    on QueryBuilder<LocalConversation, LocalConversation, QFilterCondition> {}

extension LocalConversationQuerySortBy
    on QueryBuilder<LocalConversation, LocalConversation, QSortBy> {
  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByConversationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByConversationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByIsTyping() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTyping', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByIsTypingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTyping', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByLastMessageIsOwn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageIsOwn', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByLastMessageIsOwnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageIsOwn', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByLastMessagePreview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessagePreview', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByLastMessagePreviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessagePreview', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByLastMessageStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageStatus', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByLastMessageStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageStatus', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByParticipantAvatarUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantAvatarUrl', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByParticipantAvatarUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantAvatarUrl', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByParticipantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantId', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByParticipantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantId', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByParticipantIsOnline() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantIsOnline', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByParticipantIsOnlineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantIsOnline', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByParticipantLastSeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantLastSeenAt', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByParticipantLastSeenAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantLastSeenAt', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByParticipantName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantName', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByParticipantNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantName', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByUnreadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCount', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByUnreadCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCount', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension LocalConversationQuerySortThenBy
    on QueryBuilder<LocalConversation, LocalConversation, QSortThenBy> {
  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByConversationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByConversationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByIsTyping() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTyping', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByIsTypingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTyping', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByLastMessageIsOwn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageIsOwn', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByLastMessageIsOwnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageIsOwn', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByLastMessagePreview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessagePreview', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByLastMessagePreviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessagePreview', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByLastMessageStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageStatus', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByLastMessageStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageStatus', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByParticipantAvatarUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantAvatarUrl', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByParticipantAvatarUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantAvatarUrl', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByParticipantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantId', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByParticipantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantId', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByParticipantIsOnline() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantIsOnline', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByParticipantIsOnlineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantIsOnline', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByParticipantLastSeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantLastSeenAt', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByParticipantLastSeenAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantLastSeenAt', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByParticipantName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantName', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByParticipantNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantName', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByUnreadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCount', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByUnreadCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCount', Sort.desc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension LocalConversationQueryWhereDistinct
    on QueryBuilder<LocalConversation, LocalConversation, QDistinct> {
  QueryBuilder<LocalConversation, LocalConversation, QDistinct>
      distinctByConversationId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'conversationId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QDistinct>
      distinctByIsTyping() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isTyping');
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QDistinct>
      distinctByLastMessageIsOwn() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMessageIsOwn');
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QDistinct>
      distinctByLastMessagePreview({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMessagePreview',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QDistinct>
      distinctByLastMessageStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMessageStatus',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QDistinct>
      distinctByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncedAt');
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QDistinct>
      distinctByParticipantAvatarUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'participantAvatarUrl',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QDistinct>
      distinctByParticipantId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'participantId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QDistinct>
      distinctByParticipantIsOnline() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'participantIsOnline');
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QDistinct>
      distinctByParticipantLastSeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'participantLastSeenAt');
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QDistinct>
      distinctByParticipantName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'participantName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QDistinct>
      distinctByUnreadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unreadCount');
    });
  }

  QueryBuilder<LocalConversation, LocalConversation, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension LocalConversationQueryProperty
    on QueryBuilder<LocalConversation, LocalConversation, QQueryProperty> {
  QueryBuilder<LocalConversation, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalConversation, String, QQueryOperations>
      conversationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'conversationId');
    });
  }

  QueryBuilder<LocalConversation, bool, QQueryOperations> isTypingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isTyping');
    });
  }

  QueryBuilder<LocalConversation, bool, QQueryOperations>
      lastMessageIsOwnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMessageIsOwn');
    });
  }

  QueryBuilder<LocalConversation, String, QQueryOperations>
      lastMessagePreviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMessagePreview');
    });
  }

  QueryBuilder<LocalConversation, String, QQueryOperations>
      lastMessageStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMessageStatus');
    });
  }

  QueryBuilder<LocalConversation, DateTime?, QQueryOperations>
      lastSyncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncedAt');
    });
  }

  QueryBuilder<LocalConversation, String?, QQueryOperations>
      participantAvatarUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'participantAvatarUrl');
    });
  }

  QueryBuilder<LocalConversation, String, QQueryOperations>
      participantIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'participantId');
    });
  }

  QueryBuilder<LocalConversation, bool, QQueryOperations>
      participantIsOnlineProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'participantIsOnline');
    });
  }

  QueryBuilder<LocalConversation, DateTime?, QQueryOperations>
      participantLastSeenAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'participantLastSeenAt');
    });
  }

  QueryBuilder<LocalConversation, String, QQueryOperations>
      participantNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'participantName');
    });
  }

  QueryBuilder<LocalConversation, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<LocalConversation, int, QQueryOperations> unreadCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unreadCount');
    });
  }

  QueryBuilder<LocalConversation, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
