import 'package:flutter/material.dart';

import '../../../extensions/context_extension.dart';

Future<T?> showContentDialog<T>({
  required BuildContext context,
  bool barrierDismissible = true,
  required Widget contentWidget,
}) {
  return showDialog<T?>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) => GestureDetector(
      onTap: context.hideKeyboard,
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              contentWidget,
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  '閉じる',
                  style: context.bodyStyle.copyWith(color: Colors.grey),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
