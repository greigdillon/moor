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


  void writeFromJson(_buffer, MoorTable table, Scope scope) {
    final serializerType = scope.nullableType('ValueSerializer');
    final _runtimeOptions = scope.generationOptions.writeForMoorPackage
        ? 'moorRuntimeOptions'
        : 'driftRuntimeOptions';

    final dataClassName = table.getNameForCompanionClass(scope.options);

    _buffer
      ..write('factory $dataClassName.fromJson('
          'Map<String, dynamic> json, {$serializerType serializer}'
          ') {\n')
      ..write('serializer ??= $_runtimeOptions.defaultSerializer;\n')
      ..write('return $dataClassName(');

    for (final column in table.columns) {

      final getter = column.dartGetterName;
      final jsonKey = column.getJsonKey(scope.options);
      final type = column.dartTypeCode(scope.generationOptions);


      _buffer.write("$getter: Value(serializer.fromJson<$type>(json['$jsonKey'])),");
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

