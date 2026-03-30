import 'package:flutter/material.dart';
import 'package:asmrapp/core/settings/app_settings_service.dart';

class AudioFormatOrderDialog extends StatefulWidget {
  final AppSettingsService settings;

  const AudioFormatOrderDialog({super.key, required this.settings});

  @override
  State<AudioFormatOrderDialog> createState() => _AudioFormatOrderDialogState();
}

class _AudioFormatOrderDialogState extends State<AudioFormatOrderDialog> {
  late List<String> _formats;

  @override
  void initState() {
    super.initState();
    _formats = List.from(widget.settings.audioFormatOrder);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('音频格式偏好'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '拖拽调整优先级，排在前面的格式优先播放',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ReorderableListView.builder(
                shrinkWrap: true,
                itemCount: _formats.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    key: ValueKey(_formats[index]),
                    leading: Text(
                      '${index + 1}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(_formats[index].toUpperCase()),
                    trailing: const Icon(Icons.drag_handle),
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _formats.removeAt(oldIndex);
                    _formats.insert(newIndex, item);
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _formats = List.from(AppSettingsService.defaultAudioFormatOrder);
            });
          },
          child: const Text('重置'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            widget.settings.setAudioFormatOrder(_formats);
            Navigator.pop(context);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
