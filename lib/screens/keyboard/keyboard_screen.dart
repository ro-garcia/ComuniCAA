import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';

import '../../providers/communication_provider.dart';
import '../../widgets/message_bar.dart';

class KeyboardScreen extends StatefulWidget {
  const KeyboardScreen({super.key});

  @override
  State<KeyboardScreen> createState() => _KeyboardScreenState();
}

class _KeyboardScreenState extends State<KeyboardScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const MessageBar(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              TextField(
                controller: _controller,
                minLines: 5,
                maxLines: 8,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: 'Frase manual',
                  hintText: 'Escribe aqui...',
                  alignLabelWithHint: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.add_comment_outlined),
                    label: const Text('Agregar al mensaje'),
                    onPressed: _controller.text.trim().isEmpty
                        ? null
                        : () {
                            context
                                .read<CommunicationProvider>()
                                .setManualSentence(_controller.text);
                            FocusScope.of(context).unfocus();
                          },
                  ),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.volume_up_outlined),
                    label: const Text('Hablar'),
                    onPressed: _controller.text.trim().isEmpty
                        ? null
                        : () {
                            final sentence = _controller.text.trim();
                            SemanticsService.sendAnnouncement(
                              View.of(context),
                              sentence,
                              Directionality.of(context),
                            );
                          },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
