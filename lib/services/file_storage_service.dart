import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
class FileStorageService {
  Future<String> persistReadingPhoto({required String sourcePath, required int meterId, required String localId}) async {
    final root=await getApplicationDocumentsDirectory();
    final dir=Directory(path.join(root.path,'reading_photos','meter_$meterId'));
    if(!await dir.exists()) await dir.create(recursive:true);
    final ext=path.extension(sourcePath).isEmpty?'.jpg':path.extension(sourcePath);
    final target=path.join(dir.path,'$localId$ext');
    await File(sourcePath).copy(target);
    return target;
  }
}
