import 'package:flutter/material.dart';

class InlineEditableTitle extends StatefulWidget {
  final String initialText;
  final TextStyle? style;
  final ValueChanged<String> onSubmitted;

  const InlineEditableTitle({
    super.key,
    required this.initialText,
    this.style,
    required this.onSubmitted,
  });

  @override
  State<InlineEditableTitle> createState() => _InlineEditableTitleState();
}

class _InlineEditableTitleState extends State<InlineEditableTitle> {
  bool _isEditing = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant InlineEditableTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialText != oldWidget.initialText && !_isEditing) {
      _controller.text = widget.initialText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (!_isEditing) return;

    setState(() {
      _isEditing = false;
    });

    final newText = _controller.text.trim();
    if (newText.isNotEmpty && newText != widget.initialText) {
      widget.onSubmitted(newText);
    } else {
      _controller.text = widget.initialText; // Revert if empty
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle =
        Theme.of(context).textTheme.titleLarge ??
        const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
    final activeStyle = widget.style ?? defaultStyle;

    if (_isEditing) {
      return TapRegion(
        onTapOutside: (_) => _saveChanges(),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          style: activeStyle,
          maxLines: 1,
          // This removes the underline and extra padding, making it look seamless
          decoration: const InputDecoration.collapsed(hintText: ''),
          onSubmitted: (_) => _saveChanges(),
        ),
      );
    }

    return InkWell(
      onTap: () {
        setState(() {
          _isEditing = true;
        });
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(_controller.text, style: activeStyle),
      ),
    );
  }
}
