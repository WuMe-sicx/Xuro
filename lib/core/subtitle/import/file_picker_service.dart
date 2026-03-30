import 'package:file_picker/file_picker.dart';
import 'package:asmrapp/core/subtitle/import/i_file_picker_service.dart';

class FilePickerService implements IFilePickerService {
  @override
  Future<String?> pickSubtitleFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['vtt', 'lrc'],
      allowMultiple: false,
    );
    return result?.files.single.path;
  }
}
