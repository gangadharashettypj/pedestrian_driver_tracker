import 'dart:typed_data';

extension StringExtension on String {
  Uint8List get uInt8List {
    return Uint8List.fromList(this.codeUnits);
  }
}