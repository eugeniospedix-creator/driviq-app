import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/dq_tokens.dart';
import '../animations/fade_slide_in.dart';

class DqAsyncBody<T> extends StatelessWidget {
  const DqAsyncBody({
    super.key,
    required this.asyncValue,
    required this.builder,
    this.loading,
    this.errorMessage = 'Something went wrong. Please try again.',
  });

  final AsyncValue<T> asyncValue;
  final Widget Function(T data) builder;
  final Widget? loading;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      loading: () => loading ?? const DqLoadingShell(),
      error: (error, _) => DqErrorState(
        message: error is Exception ? error.toString() : errorMessage,
      ),
      data: builder,
    );
  }
}

class DqErrorState extends StatelessWidget {
  const DqErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: DQ.coral, size: 36),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: DQ.textSecondary, height: 1.4),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              GestureDetector(
                onTap: onRetry,
                child: const Text(
                  'RETRY',
                  style: TextStyle(
                    color: DQ.cyan,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
