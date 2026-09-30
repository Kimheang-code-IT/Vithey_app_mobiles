import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';

class VerificationNextStepsCard extends StatelessWidget {
  const VerificationNextStepsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What happens next?',
            style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: context.appColors.heading),
          ),
          const SizedBox(height: 10),
          Text(
            'Our verification team is reviewing your documents. This typically takes 24 - 48 hours.',
            style: context.text.bodySmall?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 10),
          Text(
            "You'll receive an email notification once your verification is complete.",
            style: context.text.bodySmall?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}
