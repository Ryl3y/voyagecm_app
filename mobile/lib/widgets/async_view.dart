import 'package:flutter/material.dart';

import '../utils/format.dart';

/// Affiche un chargement, puis une erreur avec « Réessayer », puis [builder].
class FutureView<T> extends StatelessWidget {
  const FutureView({
    super.key,
    required this.future,
    required this.onRetry,
    required this.builder,
  });

  final Future<T> future;
  final VoidCallback onRetry;
  final Widget Function(BuildContext context, T data) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: ErrorRetry(
              message: errorText(snapshot.error!),
              onRetry: onRetry,
            ),
          );
        }
        return builder(context, snapshot.data as T);
      },
    );
  }
}

class ErrorRetry extends StatelessWidget {
  const ErrorRetry({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}

/// Bouton principal qui affiche un indicateur et se désactive pendant [busy].
class BusyButton extends StatelessWidget {
  const BusyButton({
    super.key,
    required this.busy,
    required this.onPressed,
    required this.label,
    this.icon,
  });

  final bool busy;
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    const spinner = SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
    if (icon != null) {
      return FilledButton.icon(
        onPressed: busy ? null : onPressed,
        icon: busy ? spinner : Icon(icon),
        label: Text(label),
      );
    }
    return FilledButton(
      onPressed: busy ? null : onPressed,
      child: busy ? spinner : Text(label),
    );
  }
}
