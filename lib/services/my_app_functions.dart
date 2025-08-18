import 'package:flutter/material.dart';
import 'package:shop_smart/services/app_manager.dart';
import 'package:shop_smart/widgets/subtitle_text.dart';

class MyAppFunctions {
  static Future<void> showErrorOrWarningDialog({
    required BuildContext context,
    required Function fct,
    required String subtitle,
    bool isError = true,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [],
          shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                isError ? AssetsManager.error : AssetsManager.warning,
                height: 60,
                width: 60,
              ),
              const SizedBox(height: 16),
              SubtitleTextWidget(label: "Error", fontWeight: FontWeight.w600),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: !isError,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: SubtitleTextWidget(
                        label: subtitle,
                        color: Colors.green,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: SubtitleTextWidget(
                      label: "Cancel",
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
