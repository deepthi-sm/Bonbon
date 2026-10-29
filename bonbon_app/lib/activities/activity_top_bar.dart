import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';

/// The top of every activity screen: how far along she is, and « Passer »
/// (plan §J.3 rule 4: « Always a way forward » — `allowSkip` is true on every
/// MVP activity). [onSkip] null hides the button.
class ActivityTopBar extends StatelessWidget {
  final int total, index;
  final VoidCallback? onSkip;
  const ActivityTopBar({super.key, required this.total, required this.index, this.onSkip});

  @override
  Widget build(BuildContext context) => Row(children: [
        for (var i = 0; i < total; i++)
          Expanded(
            child: Container(
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: i < index ? C.teal : i == index ? C.tealMid : C.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        if (onSkip != null) ...[
          const SizedBox(width: 6),
          TextButton.icon(
            onPressed: onSkip,
            icon: const Icon(Icons.skip_next_rounded),
            label: Text(context.tr('Passer', 'Skip')),
          ),
        ],
      ]);
}
