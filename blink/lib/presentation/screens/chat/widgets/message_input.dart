import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MessageInput extends StatefulWidget {
  final ValueChanged<String> onSendText;
  final ValueChanged<String> onSendImage; // imagePath
  final ValueChanged<bool> onTypingChanged;

  const MessageInput({
    super.key,
    required this.onSendText,
    required this.onSendImage,
    required this.onTypingChanged,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _ctrl = TextEditingController();
  bool _wasTyping = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onChanged);
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    final isTyping = _ctrl.text.trim().isNotEmpty;
    if (isTyping != _wasTyping) {
      _wasTyping = isTyping;
      widget.onTypingChanged(isTyping);
    }
    setState(() {});
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1600,
    );
    if (picked != null) {
      widget.onSendImage(picked.path);
    }
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onSendText(text);
    _ctrl.clear();
    widget.onTypingChanged(false);
    _wasTyping = false;
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _ctrl.text.trim().isNotEmpty;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        color: Colors.white.withOpacity(0.6),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _pickImage,
            ),
            Expanded(
              child: TextField(
                key: const ValueKey('message-input-field'),
                controller: _ctrl,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Xabar yozing…",
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            IconButton(
              key: const ValueKey('send-button'),
              icon: const Icon(Icons.send),
              color: Colors.blue,
              onPressed: canSend ? _send : null,
            ),
          ],
        ),
      ),
    );
  }
}
