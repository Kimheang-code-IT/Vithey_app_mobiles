import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/data/models/payment_args.dart';
import 'package:aub_connect_app/data/models/payment_invoice_model.dart';
import 'package:aub_connect_app/modules/finance/payment/payment_controller.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class PaymentScreen extends GetView<PaymentController> {
  const PaymentScreen({super.key});

  bool get _isAcleda => controller.args.method == PaymentMethodType.acleda;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          _isAcleda ? 'Pay With Acleda' : 'Pay With Another Bank',
          style: context.text.titleLarge,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: context.appColors.border),
        ),
      ),
      body: Obx(() {
        switch (controller.status.value) {
          case PaymentFlowStatus.collecting:
            return _CollectingView(isAcleda: _isAcleda);
          case PaymentFlowStatus.processing:
            return const _ProcessingView();
          case PaymentFlowStatus.success:
            return _SuccessView(isAcleda: _isAcleda);
        }
      }),
    );
  }
}

class _CollectingView extends GetView<PaymentController> {
  const _CollectingView({required this.isAcleda});

  final bool isAcleda;

  @override
  Widget build(BuildContext context) {
    final invoice = controller.args.invoice;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InvoiceSummaryCard(invoice: invoice),
            const SizedBox(height: 24),
            if (isAcleda) const _AcledaQrPanel() else const _BankTransferPanel(),
            const SizedBox(height: 24),
            CustomButton(
              label: isAcleda ? "I've Completed the Payment" : "I've Made the Transfer",
              onPressed: controller.confirmPayment,
            ),
            const SizedBox(height: 12),
            Text(
              'This is a preview flow — no real payment is processed yet.',
              textAlign: TextAlign.center,
              style: context.text.bodySmall?.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceSummaryCard extends StatelessWidget {
  const _InvoiceSummaryCard({required this.invoice});

  final PaymentInvoice invoice;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.subtleShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            invoice.feeName,
            style: context.text.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            invoice.invoiceReference,
            style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: colors.muted, letterSpacing: 0.6),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                invoice.totalLabel,
                style: context.text.titleLarge?.copyWith(fontSize: 17),
              ),
              const Spacer(),
              Text(
                invoice.total.formatted,
                style: context.text.headlineSmall
                    ?.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AcledaQrPanel extends StatelessWidget {
  const _AcledaQrPanel();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.subtleShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(VitheyRadii.media),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: const VitheyIcon(LucideIcons.qrCode, size: 96, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Scan this KHQR code with your Acleda Mobile app to pay',
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: colors.heading),
          ),
        ],
      ),
    );
  }
}

class _BankTransferPanel extends StatelessWidget {
  const _BankTransferPanel();

  @override
  Widget build(BuildContext context) {
    final args = Get.find<PaymentController>().args;
    final reference = args.invoice.invoiceReference;
    final bankName = args.bankName ?? 'Acleda Bank';
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.subtleShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRANSFER DETAILS',
            style: context.text.labelMedium
                ?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.6),
          ),
          const SizedBox(height: 12),
          _CopyableRow(label: 'Bank Name', value: bankName),
          _CopyableRow(label: 'Account Name', value: 'AUB Connect School Fund'),
          _CopyableRow(label: 'Account Number', value: '0000-1234-5678'),
          _CopyableRow(label: 'Reference', value: reference),
        ],
      ),
    );
  }
}

class _CopyableRow extends StatelessWidget {
  const _CopyableRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.text.labelSmall
                      ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.4),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: context.text.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: colors.heading),
                ),
              ],
            ),
          ),
          VitheyIconButton(
            icon: LucideIcons.copy,
            variant: VitheyIconButtonVariant.neutral,
            tooltip: 'Copy',
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              Get.snackbar(AppStrings.appName, '$label copied');
            },
          ),
        ],
      ),
    );
  }
}

class _ProcessingView extends StatelessWidget {
  const _ProcessingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Confirming your payment…',
            style: TextStyle(color: context.appColors.muted),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends GetView<PaymentController> {
  const _SuccessView({required this.isAcleda});

  final bool isAcleda;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const VitheyIcon(LucideIcons.check, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 20),
            Text(
              'Payment Submitted',
              style: context.text.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              isAcleda
                  ? "We'll update your invoice once Acleda confirms the payment."
                  : "We'll update your invoice once the transfer is confirmed.",
              textAlign: TextAlign.center,
              style: context.text.bodySmall,
            ),
            const SizedBox(height: 28),
            CustomButton(
              label: 'Back to Finance',
              onPressed: controller.backToFinance,
            ),
          ],
        ),
      ),
    );
  }
}
