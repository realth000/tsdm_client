import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';

/// Show a bottom sheet that provides emojis in editor.
Future<void> showEmojiBottomSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: _EmojiBottomSheet.new,
  );
}

/// Widget to show all available emojis can use in editor.
class _EmojiBottomSheet extends StatefulWidget {
  /// Constructor.
  const _EmojiBottomSheet(this.context);

  final BuildContext context;

  @override
  State<_EmojiBottomSheet> createState() => _EmojiBottomSheetState();
}

class _EmojiBottomSheetState extends State<_EmojiBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: edgeInsetsL15T15R15B15,
        child: Column(
          children: [
            SizedBox(height: 50, child: Center(child: Text('emoji'))),
            sizedBoxW10H10,
            Expanded(
              child: Text('all emoji'),
            ),
          ],
        ),
      ),
    );
  }
}
