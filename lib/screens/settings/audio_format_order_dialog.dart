import 'package:flutter/material.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/core/settings/app_settings_service.dart';

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
      title: const Text(Strings.audioFormatPreference),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Strings.audioFormatHint,
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
          child: const Text(Strings.reset),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(Strings.cancel),
        ),
        FilledButton(
          onPressed: () {
            widget.settings.setAudioFormatOrder(_formats);
            Navigator.pop(context);
          },
          child: const Text(Strings.save),
        ),
      ],
    );
  }
}
