import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/status_badge.dart';
import 'package:aub_connect_app/data/models/finance_dashboard_model.dart';
import 'package:aub_connect_app/data/models/payment_invoice_model.dart';
import 'package:aub_connect_app/modules/finance/payment/acleda_mobile_launcher.dart';
import 'package:aub_connect_app/modules/finance/widgets/finance_status_colors.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class InvoicePreviewSheet {
  static Future<void> show({
    required PaymentInvoice invoice,
    required Future<void> Function() onDownload,
  }) {
    final context = Get.context!;
    return Get.bottomSheet<void>(
      _InvoiceSheet(invoice: invoice, onDownload: onDownload),
      isScrollControlled: true,
      backgroundColor: context.scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(VitheyRadii.sheet)),
      ),
    );
  }
}

class _InvoiceSheet extends StatefulWidget {
  const _InvoiceSheet({required this.invoice, required this.onDownload});

  final PaymentInvoice invoice;
  final Future<void> Function() onDownload;

  @override
  State<_InvoiceSheet> createState() => _InvoiceSheetState();
}

class _InvoiceSheetState extends State<_InvoiceSheet> {
  bool _downloading = false;

  Future<void> _download() async {
    setState(() => _downloading = true);
    try {
      await widget.onDownload();
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _payWithAcleda() async {
    Get.back();
    await AcledaMobileLauncher.open();
  }

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;
    final theme = _InvoiceTheme.fromStatus(invoice.status);
    final date = invoice.status == PaymentStatus.paid ? invoice.paidAt : invoice.dueAt;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.appColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                invoice.feeName,
                textAlign: TextAlign.center,
                style: context.text.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                invoice.invoiceReference,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: context.appColors.muted, letterSpacing: 0.6),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.panelFill,
                  borderRadius: BorderRadius.circular(VitheyRadii.card),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STATUS',
                            style: context.text.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          StatusBadge(
                            label: invoice.statusLabel,
                            color: theme.accent,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'DATE',
                            style: context.text.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            date != null ? _formatDate(date) : '—',
                            style: context.text.labelLarge?.copyWith(
                              color: theme.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'BREAKDOWN',
                style: context.text.labelMedium
                    ?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.6),
              ),
              const SizedBox(height: 12),
              _BreakdownRow(
                label: 'Base Amount',
                value: invoice.baseAmount.formatted,
              ),
              _BreakdownRow(
                label: 'Processing Fee',
                value: invoice.processingFee.formatted,
              ),
              _BreakdownRow(
                label: 'Late Charge',
                value: invoice.lateCharges.formatted,
                valueColor: theme.moneyAccent,
              ),
              Divider(height: 28, color: context.appColors.border),
              Row(
                children: [
                  Text(
                    'Total Due',
                    style: context.text.titleLarge?.copyWith(fontSize: 17),
                  ),
                  const Spacer(),
                  Text(
                    invoice.total.formatted,
                    style: context.text.headlineSmall
                        ?.copyWith(color: theme.moneyAccent),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              if (invoice.status == PaymentStatus.paid) ...[
                _InvoiceActionButton(
                  label: 'Download PDF Invoice',
                  icon: LucideIcons.download,
                  isLoading: _downloading,
                  onPressed: _download,
                ),
                const SizedBox(height: 10),
                _InvoiceActionButton(
                  label: 'Report an Issue (Coming Soon)',
                  icon: LucideIcons.circleHelp,
                  variant: CustomButtonVariant.outline,
                  onPressed: null,
                ),
              ] else ...[
                _InvoiceActionButton(
                  label: 'Pay with ACLEDA',
                  icon: LucideIcons.wallet,
                  onPressed: _payWithAcleda,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _InvoiceTheme {
  const _InvoiceTheme({
    required this.panelFill,
    required this.accent,
    required this.moneyAccent,
  });

  final Color panelFill;
  final Color accent;
  final Color moneyAccent;

  factory _InvoiceTheme.fromStatus(PaymentStatus status) {
    final color = FinanceStatusColors.invoiceAccent(status);
    return _InvoiceTheme(
      panelFill: FinanceStatusColors.invoicePanelFill(status),
      accent: color,
      moneyAccent: color,
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: context.appColors.muted)),
          const Spacer(),
          Text(
            value,
            style: context.text.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: valueColor ?? context.appColors.heading),
          ),
        ],
      ),
    );
  }
}

class _InvoiceActionButton extends StatelessWidget {
  const _InvoiceActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.variant = CustomButtonVariant.primary,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final CustomButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      label: label,
      icon: icon,
      isLoading: isLoading,
      variant: variant,
      onPressed: isLoading ? null : onPressed,
    );
  }
}
