import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';

/// Shows a generic popup dialog.
///
/// [title] is the title of the dialog.
/// [message] is the content of the dialog.
/// [buttonText] is the text for the primary button (default: "OK").
/// [onPressed] is the callback for the primary button. If null, the button just closes the dialog.
/// [isError] if true, makes the title red to indicate an error.
void showCustomPopup({
  required BuildContext context,
  required String title,
  required String message,
  String? buttonText,
  VoidCallback? onPressed,
  bool isError = false,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: TextStyle(
          color: isError
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(message, style: const TextStyle(fontSize: 16)),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            if (onPressed != null) {
              onPressed();
            }
          },
          child: Text(
            buttonText ?? 'OK',
            style: TextStyle(
              color: isError
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Helper for showing error messages
void showErrorPopup(
  BuildContext context,
  String message, {
  VoidCallback? onRetry,
  String? retryText,
}) {
  showCustomPopup(
    context: context,
    title: AppLocalizations.of(context).errorTitle,
    message: message,
    isError: true,
    buttonText: onRetry != null ? (retryText ?? AppLocalizations.of(context).retry) : 'OK',
    onPressed: onRetry,
  );
}

/// Helper for showing success messages
void showSuccessPopup(BuildContext context, String message) {
  showCustomPopup(
    context: context,
    title: AppLocalizations.of(context).successTitle,
    message: message,
    isError: false,
    buttonText: AppLocalizations.of(context).great,
  );
}
