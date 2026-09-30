import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/startup_profile_draft.dart';
import 'package:aub_connect_app/modules/auth/startup/startup_controller.dart';
import 'package:aub_connect_app/modules/auth/startup/widgets/discovery_source_row.dart';
import 'package:aub_connect_app/modules/auth/startup/widgets/selectable_interest_card.dart';
import 'package:aub_connect_app/modules/auth/startup/widgets/packed_skill_chip_flow.dart';

class StartupSkillsPage extends GetView<StartupController> {
  const StartupSkillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            'What are your skills?',
            style: context.text.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Select your top skills to stand out to employers.',
            style: context.text.bodySmall?.copyWith(fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GetBuilder<StartupController>(
            builder: (_) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PackedSkillChipFlow(
                skills: startupSkills,
                selectedIds: controller.draft.skillIds.toSet(),
                onToggle: controller.toggleSkill,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StartupInterestsPage extends GetView<StartupController> {
  const StartupInterestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            'What are you interested in?',
            style: context.text.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Choose your favorite topics to personalize your feed.',
            style: context.text.bodySmall?.copyWith(fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GetBuilder<StartupController>(
            builder: (_) => GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.9,
              ),
              itemCount: startupInterests.length,
              itemBuilder: (_, index) {
                final item = startupInterests[index];
                final selected = controller.draft.interestIds.contains(item.id);
                return SelectableInterestCard(
                  label: item.label,
                  icon: item.icon,
                  selected: selected,
                  onTap: () => controller.toggleInterest(item.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class StartupDiscoveryPage extends GetView<StartupController> {
  const StartupDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            'How did you find us?',
            style: context.text.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Select one option to help us improve your experience.',
            style: context.text.bodySmall?.copyWith(fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GetBuilder<StartupController>(
            builder: (_) => ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: startupDiscoveryOptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final item = startupDiscoveryOptions[index];
                final selected = controller.draft.discoverySource == item.id;
                return DiscoverySourceRow(
                  label: item.label,
                  icon: item.icon,
                  selected: selected,
                  onTap: () => controller.selectDiscovery(item.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
