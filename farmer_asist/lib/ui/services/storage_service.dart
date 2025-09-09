import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static Future<String> saveImage(File file, {String? fileName}) async {
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/${fileName ?? DateTime.now().millisecondsSinceEpoch}.png';
    final newFile = await file.copy(path);
    return newFile.path;
  }
}
