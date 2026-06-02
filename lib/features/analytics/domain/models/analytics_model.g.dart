// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAnalyticsModelCollection on Isar {
  IsarCollection<AnalyticsModel> get analyticsModels => this.collection();
}

const AnalyticsModelSchema = CollectionSchema(
  name: r'AnalyticsModel',
  id: -105659631057071516,
  properties: {
    r'aggregateTimeSeconds': PropertySchema(
      id: 0,
      name: r'aggregateTimeSeconds',
      type: IsarType.long,
    ),
    r'averageAccuracy': PropertySchema(
      id: 1,
      name: r'averageAccuracy',
      type: IsarType.double,
    ),
    r'lastPracticedAt': PropertySchema(
      id: 2,
      name: r'lastPracticedAt',
      type: IsarType.dateTime,
    ),
    r'subject': PropertySchema(
      id: 3,
      name: r'subject',
      type: IsarType.string,
    ),
    r'topic': PropertySchema(
      id: 4,
      name: r'topic',
      type: IsarType.string,
    ),
    r'totalCorrect': PropertySchema(
      id: 5,
      name: r'totalCorrect',
      type: IsarType.long,
    ),
    r'totalQuestionsAttempted': PropertySchema(
      id: 6,
      name: r'totalQuestionsAttempted',
      type: IsarType.long,
    ),
    r'totalSessionsPracticed': PropertySchema(
      id: 7,
      name: r'totalSessionsPracticed',
      type: IsarType.long,
    )
  },
  estimateSize: _analyticsModelEstimateSize,
  serialize: _analyticsModelSerialize,
  deserialize: _analyticsModelDeserialize,
  deserializeProp: _analyticsModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'subject': IndexSchema(
      id: 3257156273020483090,
      name: r'subject',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'subject',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _analyticsModelGetId,
  getLinks: _analyticsModelGetLinks,
  attach: _analyticsModelAttach,
  version: '3.1.0+1',
);

int _analyticsModelEstimateSize(
  AnalyticsModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.subject.length * 3;
  bytesCount += 3 + object.topic.length * 3;
  return bytesCount;
}

void _analyticsModelSerialize(
  AnalyticsModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.aggregateTimeSeconds);
  writer.writeDouble(offsets[1], object.averageAccuracy);
  writer.writeDateTime(offsets[2], object.lastPracticedAt);
  writer.writeString(offsets[3], object.subject);
  writer.writeString(offsets[4], object.topic);
  writer.writeLong(offsets[5], object.totalCorrect);
  writer.writeLong(offsets[6], object.totalQuestionsAttempted);
  writer.writeLong(offsets[7], object.totalSessionsPracticed);
}

AnalyticsModel _analyticsModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AnalyticsModel();
  object.aggregateTimeSeconds = reader.readLong(offsets[0]);
  object.averageAccuracy = reader.readDouble(offsets[1]);
  object.id = id;
  object.lastPracticedAt = reader.readDateTime(offsets[2]);
  object.subject = reader.readString(offsets[3]);
  object.topic = reader.readString(offsets[4]);
  object.totalCorrect = reader.readLong(offsets[5]);
  object.totalQuestionsAttempted = reader.readLong(offsets[6]);
  object.totalSessionsPracticed = reader.readLong(offsets[7]);
  return object;
}

P _analyticsModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _analyticsModelGetId(AnalyticsModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _analyticsModelGetLinks(AnalyticsModel object) {
  return [];
}

void _analyticsModelAttach(
    IsarCollection<dynamic> col, Id id, AnalyticsModel object) {
  object.id = id;
}

extension AnalyticsModelByIndex on IsarCollection<AnalyticsModel> {
  Future<AnalyticsModel?> getBySubject(String subject) {
    return getByIndex(r'subject', [subject]);
  }

  AnalyticsModel? getBySubjectSync(String subject) {
    return getByIndexSync(r'subject', [subject]);
  }

  Future<bool> deleteBySubject(String subject) {
    return deleteByIndex(r'subject', [subject]);
  }

  bool deleteBySubjectSync(String subject) {
    return deleteByIndexSync(r'subject', [subject]);
  }

  Future<List<AnalyticsModel?>> getAllBySubject(List<String> subjectValues) {
    final values = subjectValues.map((e) => [e]).toList();
    return getAllByIndex(r'subject', values);
  }

  List<AnalyticsModel?> getAllBySubjectSync(List<String> subjectValues) {
    final values = subjectValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'subject', values);
  }

  Future<int> deleteAllBySubject(List<String> subjectValues) {
    final values = subjectValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'subject', values);
  }

  int deleteAllBySubjectSync(List<String> subjectValues) {
    final values = subjectValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'subject', values);
  }

  Future<Id> putBySubject(AnalyticsModel object) {
    return putByIndex(r'subject', object);
  }

  Id putBySubjectSync(AnalyticsModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'subject', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySubject(List<AnalyticsModel> objects) {
    return putAllByIndex(r'subject', objects);
  }

  List<Id> putAllBySubjectSync(List<AnalyticsModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'subject', objects, saveLinks: saveLinks);
  }
}

extension AnalyticsModelQueryWhereSort
    on QueryBuilder<AnalyticsModel, AnalyticsModel, QWhere> {
  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AnalyticsModelQueryWhere
    on QueryBuilder<AnalyticsModel, AnalyticsModel, QWhereClause> {
  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterWhereClause>
      subjectEqualTo(String subject) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'subject',
        value: [subject],
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterWhereClause>
      subjectNotEqualTo(String subject) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subject',
              lower: [],
              upper: [subject],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subject',
              lower: [subject],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subject',
              lower: [subject],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subject',
              lower: [],
              upper: [subject],
              includeUpper: false,
            ));
      }
    });
  }
}

extension AnalyticsModelQueryFilter
    on QueryBuilder<AnalyticsModel, AnalyticsModel, QFilterCondition> {
  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      aggregateTimeSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aggregateTimeSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      aggregateTimeSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aggregateTimeSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      aggregateTimeSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aggregateTimeSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      aggregateTimeSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aggregateTimeSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      averageAccuracyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'averageAccuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      averageAccuracyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'averageAccuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      averageAccuracyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'averageAccuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      averageAccuracyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'averageAccuracy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
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

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
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

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      lastPracticedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPracticedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      lastPracticedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPracticedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      lastPracticedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPracticedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      lastPracticedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPracticedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      subjectEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      subjectGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      subjectLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      subjectBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subject',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      subjectStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      subjectEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      subjectContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      subjectMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subject',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      subjectIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subject',
        value: '',
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      subjectIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subject',
        value: '',
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      topicEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      topicGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      topicLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      topicBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'topic',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      topicStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      topicEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      topicContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      topicMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'topic',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      topicIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topic',
        value: '',
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      topicIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'topic',
        value: '',
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      totalCorrectEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCorrect',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      totalCorrectGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCorrect',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      totalCorrectLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCorrect',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      totalCorrectBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCorrect',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      totalQuestionsAttemptedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalQuestionsAttempted',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      totalQuestionsAttemptedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalQuestionsAttempted',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      totalQuestionsAttemptedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalQuestionsAttempted',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      totalQuestionsAttemptedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalQuestionsAttempted',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      totalSessionsPracticedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalSessionsPracticed',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      totalSessionsPracticedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalSessionsPracticed',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      totalSessionsPracticedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalSessionsPracticed',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterFilterCondition>
      totalSessionsPracticedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalSessionsPracticed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AnalyticsModelQueryObject
    on QueryBuilder<AnalyticsModel, AnalyticsModel, QFilterCondition> {}

extension AnalyticsModelQueryLinks
    on QueryBuilder<AnalyticsModel, AnalyticsModel, QFilterCondition> {}

extension AnalyticsModelQuerySortBy
    on QueryBuilder<AnalyticsModel, AnalyticsModel, QSortBy> {
  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      sortByAggregateTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aggregateTimeSeconds', Sort.asc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      sortByAggregateTimeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aggregateTimeSeconds', Sort.desc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      sortByAverageAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAccuracy', Sort.asc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      sortByAverageAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAccuracy', Sort.desc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      sortByLastPracticedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPracticedAt', Sort.asc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      sortByLastPracticedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPracticedAt', Sort.desc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy> sortBySubject() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.asc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      sortBySubjectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.desc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy> sortByTopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.asc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy> sortByTopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.desc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      sortByTotalCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCorrect', Sort.asc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      sortByTotalCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCorrect', Sort.desc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      sortByTotalQuestionsAttempted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuestionsAttempted', Sort.asc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      sortByTotalQuestionsAttemptedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuestionsAttempted', Sort.desc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      sortByTotalSessionsPracticed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSessionsPracticed', Sort.asc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      sortByTotalSessionsPracticedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSessionsPracticed', Sort.desc);
    });
  }
}

extension AnalyticsModelQuerySortThenBy
    on QueryBuilder<AnalyticsModel, AnalyticsModel, QSortThenBy> {
  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      thenByAggregateTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aggregateTimeSeconds', Sort.asc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      thenByAggregateTimeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aggregateTimeSeconds', Sort.desc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      thenByAverageAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAccuracy', Sort.asc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      thenByAverageAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAccuracy', Sort.desc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      thenByLastPracticedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPracticedAt', Sort.asc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      thenByLastPracticedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPracticedAt', Sort.desc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy> thenBySubject() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.asc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      thenBySubjectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.desc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy> thenByTopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.asc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy> thenByTopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.desc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      thenByTotalCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCorrect', Sort.asc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      thenByTotalCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCorrect', Sort.desc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      thenByTotalQuestionsAttempted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuestionsAttempted', Sort.asc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      thenByTotalQuestionsAttemptedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuestionsAttempted', Sort.desc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      thenByTotalSessionsPracticed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSessionsPracticed', Sort.asc);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QAfterSortBy>
      thenByTotalSessionsPracticedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSessionsPracticed', Sort.desc);
    });
  }
}

extension AnalyticsModelQueryWhereDistinct
    on QueryBuilder<AnalyticsModel, AnalyticsModel, QDistinct> {
  QueryBuilder<AnalyticsModel, AnalyticsModel, QDistinct>
      distinctByAggregateTimeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aggregateTimeSeconds');
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QDistinct>
      distinctByAverageAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'averageAccuracy');
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QDistinct>
      distinctByLastPracticedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPracticedAt');
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QDistinct> distinctBySubject(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subject', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QDistinct> distinctByTopic(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topic', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QDistinct>
      distinctByTotalCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCorrect');
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QDistinct>
      distinctByTotalQuestionsAttempted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalQuestionsAttempted');
    });
  }

  QueryBuilder<AnalyticsModel, AnalyticsModel, QDistinct>
      distinctByTotalSessionsPracticed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalSessionsPracticed');
    });
  }
}

extension AnalyticsModelQueryProperty
    on QueryBuilder<AnalyticsModel, AnalyticsModel, QQueryProperty> {
  QueryBuilder<AnalyticsModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AnalyticsModel, int, QQueryOperations>
      aggregateTimeSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aggregateTimeSeconds');
    });
  }

  QueryBuilder<AnalyticsModel, double, QQueryOperations>
      averageAccuracyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'averageAccuracy');
    });
  }

  QueryBuilder<AnalyticsModel, DateTime, QQueryOperations>
      lastPracticedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPracticedAt');
    });
  }

  QueryBuilder<AnalyticsModel, String, QQueryOperations> subjectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subject');
    });
  }

  QueryBuilder<AnalyticsModel, String, QQueryOperations> topicProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topic');
    });
  }

  QueryBuilder<AnalyticsModel, int, QQueryOperations> totalCorrectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCorrect');
    });
  }

  QueryBuilder<AnalyticsModel, int, QQueryOperations>
      totalQuestionsAttemptedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalQuestionsAttempted');
    });
  }

  QueryBuilder<AnalyticsModel, int, QQueryOperations>
      totalSessionsPracticedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalSessionsPracticed');
    });
  }
}
