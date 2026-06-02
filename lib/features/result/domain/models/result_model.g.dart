// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetResultModelCollection on Isar {
  IsarCollection<ResultModel> get resultModels => this.collection();
}

const ResultModelSchema = CollectionSchema(
  name: r'ResultModel',
  id: 423619455610324032,
  properties: {
    r'accuracyPercentage': PropertySchema(
      id: 0,
      name: r'accuracyPercentage',
      type: IsarType.double,
    ),
    r'correctAnswersCount': PropertySchema(
      id: 1,
      name: r'correctAnswersCount',
      type: IsarType.long,
    ),
    r'feedbackOverview': PropertySchema(
      id: 2,
      name: r'feedbackOverview',
      type: IsarType.string,
    ),
    r'incorrectAnswersCount': PropertySchema(
      id: 3,
      name: r'incorrectAnswersCount',
      type: IsarType.long,
    ),
    r'sessionId': PropertySchema(
      id: 4,
      name: r'sessionId',
      type: IsarType.string,
    ),
    r'skippedAnswersCount': PropertySchema(
      id: 5,
      name: r'skippedAnswersCount',
      type: IsarType.long,
    ),
    r'timeSpentSeconds': PropertySchema(
      id: 6,
      name: r'timeSpentSeconds',
      type: IsarType.long,
    ),
    r'totalMarksScored': PropertySchema(
      id: 7,
      name: r'totalMarksScored',
      type: IsarType.double,
    ),
    r'totalQuestions': PropertySchema(
      id: 8,
      name: r'totalQuestions',
      type: IsarType.long,
    )
  },
  estimateSize: _resultModelEstimateSize,
  serialize: _resultModelSerialize,
  deserialize: _resultModelDeserialize,
  deserializeProp: _resultModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'sessionId': IndexSchema(
      id: 6949518585047923839,
      name: r'sessionId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'sessionId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _resultModelGetId,
  getLinks: _resultModelGetLinks,
  attach: _resultModelAttach,
  version: '3.1.0+1',
);

int _resultModelEstimateSize(
  ResultModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.feedbackOverview;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.sessionId.length * 3;
  return bytesCount;
}

void _resultModelSerialize(
  ResultModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.accuracyPercentage);
  writer.writeLong(offsets[1], object.correctAnswersCount);
  writer.writeString(offsets[2], object.feedbackOverview);
  writer.writeLong(offsets[3], object.incorrectAnswersCount);
  writer.writeString(offsets[4], object.sessionId);
  writer.writeLong(offsets[5], object.skippedAnswersCount);
  writer.writeLong(offsets[6], object.timeSpentSeconds);
  writer.writeDouble(offsets[7], object.totalMarksScored);
  writer.writeLong(offsets[8], object.totalQuestions);
}

ResultModel _resultModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ResultModel();
  object.accuracyPercentage = reader.readDouble(offsets[0]);
  object.correctAnswersCount = reader.readLong(offsets[1]);
  object.feedbackOverview = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.incorrectAnswersCount = reader.readLong(offsets[3]);
  object.sessionId = reader.readString(offsets[4]);
  object.skippedAnswersCount = reader.readLong(offsets[5]);
  object.timeSpentSeconds = reader.readLong(offsets[6]);
  object.totalMarksScored = reader.readDouble(offsets[7]);
  object.totalQuestions = reader.readLong(offsets[8]);
  return object;
}

P _resultModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _resultModelGetId(ResultModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _resultModelGetLinks(ResultModel object) {
  return [];
}

void _resultModelAttach(
    IsarCollection<dynamic> col, Id id, ResultModel object) {
  object.id = id;
}

extension ResultModelByIndex on IsarCollection<ResultModel> {
  Future<ResultModel?> getBySessionId(String sessionId) {
    return getByIndex(r'sessionId', [sessionId]);
  }

  ResultModel? getBySessionIdSync(String sessionId) {
    return getByIndexSync(r'sessionId', [sessionId]);
  }

  Future<bool> deleteBySessionId(String sessionId) {
    return deleteByIndex(r'sessionId', [sessionId]);
  }

  bool deleteBySessionIdSync(String sessionId) {
    return deleteByIndexSync(r'sessionId', [sessionId]);
  }

  Future<List<ResultModel?>> getAllBySessionId(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'sessionId', values);
  }

  List<ResultModel?> getAllBySessionIdSync(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'sessionId', values);
  }

  Future<int> deleteAllBySessionId(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'sessionId', values);
  }

  int deleteAllBySessionIdSync(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'sessionId', values);
  }

  Future<Id> putBySessionId(ResultModel object) {
    return putByIndex(r'sessionId', object);
  }

  Id putBySessionIdSync(ResultModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'sessionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySessionId(List<ResultModel> objects) {
    return putAllByIndex(r'sessionId', objects);
  }

  List<Id> putAllBySessionIdSync(List<ResultModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'sessionId', objects, saveLinks: saveLinks);
  }
}

extension ResultModelQueryWhereSort
    on QueryBuilder<ResultModel, ResultModel, QWhere> {
  QueryBuilder<ResultModel, ResultModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ResultModelQueryWhere
    on QueryBuilder<ResultModel, ResultModel, QWhereClause> {
  QueryBuilder<ResultModel, ResultModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<ResultModel, ResultModel, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<ResultModel, ResultModel, QAfterWhereClause> sessionIdEqualTo(
      String sessionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sessionId',
        value: [sessionId],
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterWhereClause> sessionIdNotEqualTo(
      String sessionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ResultModelQueryFilter
    on QueryBuilder<ResultModel, ResultModel, QFilterCondition> {
  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      accuracyPercentageEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accuracyPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      accuracyPercentageGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accuracyPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      accuracyPercentageLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accuracyPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      accuracyPercentageBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accuracyPercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      correctAnswersCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctAnswersCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      correctAnswersCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'correctAnswersCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      correctAnswersCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'correctAnswersCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      correctAnswersCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'correctAnswersCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      feedbackOverviewIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'feedbackOverview',
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      feedbackOverviewIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'feedbackOverview',
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      feedbackOverviewEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'feedbackOverview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      feedbackOverviewGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'feedbackOverview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      feedbackOverviewLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'feedbackOverview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      feedbackOverviewBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'feedbackOverview',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      feedbackOverviewStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'feedbackOverview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      feedbackOverviewEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'feedbackOverview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      feedbackOverviewContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'feedbackOverview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      feedbackOverviewMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'feedbackOverview',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      feedbackOverviewIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'feedbackOverview',
        value: '',
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      feedbackOverviewIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'feedbackOverview',
        value: '',
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      incorrectAnswersCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'incorrectAnswersCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      incorrectAnswersCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'incorrectAnswersCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      incorrectAnswersCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'incorrectAnswersCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      incorrectAnswersCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'incorrectAnswersCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      sessionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      sessionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      sessionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      sessionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      sessionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      sessionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      sessionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      sessionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sessionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      sessionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      sessionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      skippedAnswersCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'skippedAnswersCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      skippedAnswersCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'skippedAnswersCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      skippedAnswersCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'skippedAnswersCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      skippedAnswersCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'skippedAnswersCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      timeSpentSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timeSpentSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      timeSpentSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timeSpentSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      timeSpentSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timeSpentSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      timeSpentSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timeSpentSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      totalMarksScoredEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalMarksScored',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      totalMarksScoredGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalMarksScored',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      totalMarksScoredLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalMarksScored',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      totalMarksScoredBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalMarksScored',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      totalQuestionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalQuestions',
        value: value,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      totalQuestionsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalQuestions',
        value: value,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      totalQuestionsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalQuestions',
        value: value,
      ));
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterFilterCondition>
      totalQuestionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalQuestions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ResultModelQueryObject
    on QueryBuilder<ResultModel, ResultModel, QFilterCondition> {}

extension ResultModelQueryLinks
    on QueryBuilder<ResultModel, ResultModel, QFilterCondition> {}

extension ResultModelQuerySortBy
    on QueryBuilder<ResultModel, ResultModel, QSortBy> {
  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      sortByAccuracyPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracyPercentage', Sort.asc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      sortByAccuracyPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracyPercentage', Sort.desc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      sortByCorrectAnswersCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswersCount', Sort.asc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      sortByCorrectAnswersCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswersCount', Sort.desc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      sortByFeedbackOverview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedbackOverview', Sort.asc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      sortByFeedbackOverviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedbackOverview', Sort.desc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      sortByIncorrectAnswersCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incorrectAnswersCount', Sort.asc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      sortByIncorrectAnswersCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incorrectAnswersCount', Sort.desc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy> sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy> sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      sortBySkippedAnswersCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skippedAnswersCount', Sort.asc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      sortBySkippedAnswersCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skippedAnswersCount', Sort.desc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      sortByTimeSpentSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeSpentSeconds', Sort.asc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      sortByTimeSpentSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeSpentSeconds', Sort.desc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      sortByTotalMarksScored() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMarksScored', Sort.asc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      sortByTotalMarksScoredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMarksScored', Sort.desc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy> sortByTotalQuestions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuestions', Sort.asc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      sortByTotalQuestionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuestions', Sort.desc);
    });
  }
}

extension ResultModelQuerySortThenBy
    on QueryBuilder<ResultModel, ResultModel, QSortThenBy> {
  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      thenByAccuracyPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracyPercentage', Sort.asc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      thenByAccuracyPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracyPercentage', Sort.desc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      thenByCorrectAnswersCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswersCount', Sort.asc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      thenByCorrectAnswersCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctAnswersCount', Sort.desc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      thenByFeedbackOverview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedbackOverview', Sort.asc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      thenByFeedbackOverviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedbackOverview', Sort.desc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      thenByIncorrectAnswersCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incorrectAnswersCount', Sort.asc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      thenByIncorrectAnswersCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incorrectAnswersCount', Sort.desc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy> thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy> thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      thenBySkippedAnswersCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skippedAnswersCount', Sort.asc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      thenBySkippedAnswersCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skippedAnswersCount', Sort.desc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      thenByTimeSpentSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeSpentSeconds', Sort.asc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      thenByTimeSpentSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeSpentSeconds', Sort.desc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      thenByTotalMarksScored() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMarksScored', Sort.asc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      thenByTotalMarksScoredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMarksScored', Sort.desc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy> thenByTotalQuestions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuestions', Sort.asc);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QAfterSortBy>
      thenByTotalQuestionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuestions', Sort.desc);
    });
  }
}

extension ResultModelQueryWhereDistinct
    on QueryBuilder<ResultModel, ResultModel, QDistinct> {
  QueryBuilder<ResultModel, ResultModel, QDistinct>
      distinctByAccuracyPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accuracyPercentage');
    });
  }

  QueryBuilder<ResultModel, ResultModel, QDistinct>
      distinctByCorrectAnswersCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctAnswersCount');
    });
  }

  QueryBuilder<ResultModel, ResultModel, QDistinct> distinctByFeedbackOverview(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'feedbackOverview',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QDistinct>
      distinctByIncorrectAnswersCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'incorrectAnswersCount');
    });
  }

  QueryBuilder<ResultModel, ResultModel, QDistinct> distinctBySessionId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ResultModel, ResultModel, QDistinct>
      distinctBySkippedAnswersCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'skippedAnswersCount');
    });
  }

  QueryBuilder<ResultModel, ResultModel, QDistinct>
      distinctByTimeSpentSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timeSpentSeconds');
    });
  }

  QueryBuilder<ResultModel, ResultModel, QDistinct>
      distinctByTotalMarksScored() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalMarksScored');
    });
  }

  QueryBuilder<ResultModel, ResultModel, QDistinct> distinctByTotalQuestions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalQuestions');
    });
  }
}

extension ResultModelQueryProperty
    on QueryBuilder<ResultModel, ResultModel, QQueryProperty> {
  QueryBuilder<ResultModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ResultModel, double, QQueryOperations>
      accuracyPercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accuracyPercentage');
    });
  }

  QueryBuilder<ResultModel, int, QQueryOperations>
      correctAnswersCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctAnswersCount');
    });
  }

  QueryBuilder<ResultModel, String?, QQueryOperations>
      feedbackOverviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feedbackOverview');
    });
  }

  QueryBuilder<ResultModel, int, QQueryOperations>
      incorrectAnswersCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'incorrectAnswersCount');
    });
  }

  QueryBuilder<ResultModel, String, QQueryOperations> sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<ResultModel, int, QQueryOperations>
      skippedAnswersCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'skippedAnswersCount');
    });
  }

  QueryBuilder<ResultModel, int, QQueryOperations> timeSpentSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timeSpentSeconds');
    });
  }

  QueryBuilder<ResultModel, double, QQueryOperations>
      totalMarksScoredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalMarksScored');
    });
  }

  QueryBuilder<ResultModel, int, QQueryOperations> totalQuestionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalQuestions');
    });
  }
}
