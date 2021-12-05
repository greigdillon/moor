import 'package:drift_dev/src/model/types.dart';
import 'package:drift_dev/src/writer/tables/data_class_writer.dart';
import 'package:drift_dev/writer.dart';

import '../../../moor_generator.dart';
extension JsonStatic on DataClassWriter{

  void writeFromJsonStatic(_buffer, _runtimeOptions) {
    final dataClassName = table.dartTypeName;

    _buffer
      ..write('static $dataClassName? fromJsonStatic('
          'dynamic json, {$serializerType serializer}'
          ') {\n')
      ..write('serializer ??= $_runtimeOptions.defaultSerializer;\n')
      ..write('return $dataClassName(');

    for (final column in table.columns) {
      final getter = column.dartGetterName;
      final jsonKey = column.getJsonKey(scope.options);
      final type = column.dartTypeCode(scope.generationOptions);

      _buffer.write("$getter: serializer.fromJson<$type>(json['$jsonKey']),");
    }

    _buffer.write(');}\n');

    if (scope.writer.options.generateFromJsonStringConstructor) {
      // also generate a constructor that only takes a json string
      _buffer.write('factory $dataClassName.fromJsonString(String encodedJson, '
          '{$serializerType serializer}) => '
          '$dataClassName.fromJson('
          'DataClass.parseJson(encodedJson) as Map<String, dynamic>, '
          'serializer: serializer);');
    }
  }
}

extension FROMJSON on UpdateCompanionWriter{


  void writeToCompanion(_buffer) {
    final asTable = table as MoorTable;

    _buffer
      ..write(asTable.getNameForCompanionClass(scope.options))
      ..write(' toCompanion(Map<String,dynamic> json, {bool nullToAbsent = true}) {\n');

    _buffer
      ..write('return ')
      ..write(asTable.getNameForCompanionClass(scope.options))
      ..write('(');

    for (final column in table.columns) {
      final dartName = column.dartGetterName;
      _buffer
        ..write(dartName)
        ..write(': ');

      final needsNullCheck = column.nullable || !scope.generationOptions.nnbd;
      if (needsNullCheck) {
        _buffer
          ..write("json['$dartName']")
          ..write(' == null && nullToAbsent ? const Value.absent() : ');
        // We'll write the non-null case afterwards
      }

      _buffer
        ..write('Value (')
        ..write(dartName)
        ..write('),');
    }

    _buffer.writeln(');\n}');
  }

  // PersonalInformationTableCompanion toCompanion(bool nullToAbsent) {
  //   return PersonalInformationTableCompanion(
  //     id: id == null && nullToAbsent ? const Value.absent() : Value(id),
  //     first_name: first_name == null && nullToAbsent
  //         ? const Value.absent()
  //         : Value(first_name),
  //     middle_name: middle_name == null && nullToAbsent
  //         ? const Value.absent()
  //         : Value(middle_name),
  //     last_name: last_name == null && nullToAbsent
  //         ? const Value.absent()
  //         : Value(last_name),
  //     date_of_birth: date_of_birth == null && nullToAbsent
  //         ? const Value.absent()
  //         : Value(date_of_birth),
  //     contact_information: contact_information == null && nullToAbsent
  //         ? const Value.absent()
  //         : Value(contact_information),
  //   );
  // }


  void writeFromJson(_buffer, MoorTable table, Scope scope) {
    final serializerType = scope.nullableType('ValueSerializer');
    final _runtimeOptions = scope.generationOptions.writeForMoorPackage
        ? 'moorRuntimeOptions'
        : 'driftRuntimeOptions';

    final dataClassName = table.getNameForCompanionClass(scope.options);
    final className = table.dartTypeName;

    _buffer
      ..write('factory $dataClassName.fromData('
          '$className json, {$serializerType serializer}'
          ') {\n')
      ..write('serializer ??= $_runtimeOptions.defaultSerializer;\n')
      ..write('return $dataClassName(');

    for (final column in table.columns) {

      final getter = column.dartGetterName;
      final jsonKey = column.getJsonKey(scope.options);
      final type = column.dartTypeCode(scope.generationOptions);


      _buffer.write("$getter: Value(json.$getter),");
    }

    _buffer.write(');}\n');

    if (scope.writer.options.generateFromJsonStringConstructor) {
      // also generate a constructor that only takes a json string
      _buffer.write('factory $dataClassName.fromJsonString(String encodedJson, '
          '{$serializerType serializer}) => '
          '$dataClassName.fromJson('
          'DataClass.parseJson(encodedJson) as Map<String, dynamic>, '
          'serializer: serializer);');
    }
  }
}

