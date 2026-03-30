/// Abstract file picker for subtitle files
abstract class IFilePickerService {
  /// Returns the picked file path, or null if cancelled
  Future<String?> pickSubtitleFile();
}
