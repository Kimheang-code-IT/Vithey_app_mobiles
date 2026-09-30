import 'package:get/get.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';

class DeleteNotificationDialog {
  static Future<bool?> show() {
    final context = Get.context;
    if (context == null) return Future.value(null);

    return showConfirmDialog(
      context: context,
      title: 'Delete notification?',
      message:
          'This removes only this notification from your list. The related post, application, message, or payment will not be deleted.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      variant: ConfirmDialogVariant.destructive,
    );
  }
}
