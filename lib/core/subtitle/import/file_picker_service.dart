import 'package:file_picker/file_picker.dart';
import 'package:xuro/core/files/file_kind.dart';

class FilePickerService {
  /// 返回用户选中的字幕文件路径；用户取消选择时返回 null。
  Future<String?> pickSubtitleFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: FileKinds.pairableSubtitleExtensions.toList(),
      allowMultiple: false,
    );
    return result?.files.single.path;
  }
}
