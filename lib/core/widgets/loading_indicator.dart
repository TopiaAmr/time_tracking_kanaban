import 'package:flutter/material.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n.dart';

/// Custom loading indicator widget.
class LoadingIndicator extends StatelessWidget {
  /// Optional message to display below the indicator.
  final String? message;

  const LoadingIndicator({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ] else ...[
            const SizedBox(height: 16),
            Text(
              context.l10n.loading,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

