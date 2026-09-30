import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:aub_connect_app/modules/profile/profile_controller.dart';
import 'package:aub_connect_app/modules/profile/widgets/edit_profile_bottom_sheet.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_section_sheets.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_skills.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class EditProfileController extends GetxController {
  EditProfileController(this._repository);

  final ProfileRepository _repository;

  final profile = Rxn<UserProfileModel>();
  final isLoading = true.obs;
  final isSaving = false.obs;

  final bio = ''.obs;
  final location = ''.obs;
  final gender = ''.obs;
  final dateOfBirth = Rxn<DateTime>();
  final skills = <ProfileSkill>[].obs;
  final workEntries = <ProfileWorkEntry>[].obs;
  final educationEntries = <ProfileEducationEntry>[].obs;
  final linkEntries = <ProfileLinkEntry>[].obs;
  final contactEntries = <ProfileContactEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final loaded =
          await _repository.getProfile(ProfileRepository.currentUserId);
      profile.value = loaded;
      bio.value = loaded.bio ?? '';
      location.value = loaded.location ?? '';
      gender.value = loaded.gender ?? '';
      dateOfBirth.value = loaded.dateOfBirth;
      skills.assignAll(loaded.skills);
      workEntries.assignAll(loaded.workItems);
      educationEntries.assignAll(loaded.educationItems);
      linkEntries.assignAll(loaded.linkItems);
      contactEntries.assignAll(loaded.contactItems);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> save() async {
    isSaving.value = true;
    try {
      final firstContact =
          contactEntries.isNotEmpty ? contactEntries.first : null;
      final firstWork = workEntries.isNotEmpty ? workEntries.first : null;
      final firstEdu =
          educationEntries.isNotEmpty ? educationEntries.first : null;

      final updated = await _repository.updateProfile(
        bio: bio.value,
        location: location.value,
        gender: gender.value,
        dateOfBirth: dateOfBirth.value,
        updateDateOfBirth: true,
        workplace: firstWork?.workplace ?? '',
        workEntries: List.of(workEntries),
        educationEntries: List.of(educationEntries),
        university: firstEdu?.school ?? '',
        major: firstEdu?.major ?? '',
        linkEntries: List.of(linkEntries),
        contactEntries: List.of(contactEntries),
        phone: firstContact?.phone ?? '',
        email: firstContact?.email ?? '',
        skills: List.of(skills),
      );
      profile.value = updated;
      await _syncProfileController(updated);
      Get.back(result: true);
      Get.snackbar(AppStrings.appName, 'Profile updated');
    } catch (e) {
      Get.snackbar(AppStrings.appName, e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  /// Persist skills immediately so All tab / profile stay in sync without
  /// relying only on the footer Save button.
  Future<void> persistSkills() async {
    try {
      final updated = await _repository.updateProfile(
        skills: List.of(skills),
      );
      profile.value = updated;
      await _syncProfileController(updated);
    } catch (e) {
      Get.snackbar(AppStrings.appName, e.toString());
    }
  }

  Future<void> _syncProfileController(UserProfileModel updated) async {
    if (!Get.isRegistered<ProfileController>()) return;
    final profileController = Get.find<ProfileController>();
    // Own profile only — never overwrite someone else's open profile.
    if (!profileController.isOwnProfile) return;
    profileController.profile.value = updated;
  }

  void cancel() => Get.back(result: false);
}

class EditProfileScreen extends GetView<EditProfileController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final heading = context.appColors.heading;
    return Scaffold(
      backgroundColor: context.appColors.bodyBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.appColors.bodyBackground,
        foregroundColor: heading,
        title: Text(
          'Edit personal info',
          style: context.text.headlineSmall?.copyWith(color: heading),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _SkillsBlock(controller: controller),
                  const SizedBox(height: 22),
                  _BioBlock(controller: controller),
                  const SizedBox(height: 22),
                  _PersonalBlock(controller: controller),
                  const SizedBox(height: 22),
                  _WorkBlock(controller: controller),
                  const SizedBox(height: 22),
                  _EducationBlock(controller: controller),
                  const SizedBox(height: 22),
                  _LinksBlock(controller: controller),
                  const SizedBox(height: 22),
                  _ContactBlock(controller: controller),
                ],
              ),
            ),
            _Footer(
              isSaving: controller.isSaving.value,
              onSave: controller.save,
              onCancel: controller.cancel,
            ),
          ],
        );
      }),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.isSaving,
    required this.onSave,
    required this.onCancel,
  });

  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: context.appColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                label: 'Save',
                isLoading: isSaving,
                onPressed: isSaving ? null : onSave,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                label: 'Cancel',
                variant: CustomButtonVariant.outline,
                onPressed: isSaving ? null : onCancel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TappableRow extends StatelessWidget {
  const _TappableRow({
    this.icon,
    required this.text,
    required this.onTap,
  });

  final IconData? icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(VitheyRadii.field),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              VitheyIcon(icon!, size: 20, color: context.appColors.muted),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                text,
                style: context.text.bodyLarge?.copyWith(height: 1.35, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillsBlock extends StatelessWidget {
  const _SkillsBlock({required this.controller});
  final EditProfileController controller;

  Future<void> _open(BuildContext context, {int? index}) async {
    final result = await showSkillSheet(
      context,
      existing: index == null ? null : controller.skills[index],
    );
    if (result == null) return;
    if (result.deleted) {
      if (index != null) {
        controller.skills.removeAt(index);
        controller.skills.refresh();
        await controller.persistSkills();
      }
      return;
    }
    final skill = result.value;
    if (skill == null) return;
    if (index != null) {
      controller.skills[index] = skill;
    } else {
      controller.skills.add(skill);
    }
    controller.skills.refresh();
    await controller.persistSkills();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.skills;
      // +1 for leading Add Skill circle
      final count = list.length + 1;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skills',
            style: context.text.titleLarge,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 124,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: count,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                if (i == 0) {
                  return ProfileAddSkillCircle(
                    onTap: () => _open(context),
                  );
                }
                final index = i - 1;
                return GestureDetector(
                  onTap: () => _open(context, index: index),
                  child: ProfileSkillRing(skill: list[index]),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _BioBlock extends StatelessWidget {
  const _BioBlock({required this.controller});
  final EditProfileController controller;

  Future<void> _open(BuildContext context) async {
    final result = await showBioSheet(context, existing: controller.bio.value);
    if (result == null) return;
    if (result.deleted) {
      controller.bio.value = '';
      return;
    }
    final value = result.value;
    if (value != null) controller.bio.value = value;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final text = controller.bio.value.trim();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bio',
            style: context.text.titleLarge,
          ),
          const SizedBox(height: 8),
          if (text.isNotEmpty)
            _TappableRow(
              text: text,
              onTap: () => _open(context),
            )
          else
            GestureDetector(
              onTap: () => _open(context),
              behavior: HitTestBehavior.opaque,
              child: Text(
                'No bio yet',
                style: TextStyle(color: context.appColors.muted),
              ),
            ),
        ],
      );
    });
  }
}

class _PersonalBlock extends StatelessWidget {
  const _PersonalBlock({required this.controller});
  final EditProfileController controller;

  Future<void> _open(BuildContext context) async {
    final result = await showPersonalDetailsSheet(
      context,
      location: controller.location.value,
      gender: controller.gender.value,
      dateOfBirth: controller.dateOfBirth.value,
    );
    if (result == null) return;
    if (result.deleted) {
      controller.location.value = '';
      controller.gender.value = '';
      controller.dateOfBirth.value = null;
      return;
    }
    final value = result.value;
    if (value == null) return;
    // Apply after sheet closes — never mutate Obx while sheet is dismissing.
    controller.location.value = value.location;
    controller.gender.value = value.gender;
    controller.dateOfBirth.value = value.dateOfBirth;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loc = controller.location.value.trim();
      final g = controller.gender.value.trim();
      final dob = controller.dateOfBirth.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileSectionAddHeader(
            title: 'Personal details',
            onAdd: () => _open(context),
          ),
          if (loc.isNotEmpty)
            _TappableRow(
              icon: LucideIcons.mapPin,
              text: loc,
              onTap: () => _open(context),
            ),
          if (g.isNotEmpty)
            _TappableRow(
              icon: LucideIcons.user,
              text: g,
              onTap: () => _open(context),
            ),
          if (dob != null)
            _TappableRow(
              icon: LucideIcons.cake,
              text: DateFormat('MMMM dd yyyy').format(dob),
              onTap: () => _open(context),
            ),
          if (loc.isEmpty && g.isEmpty && dob == null)
            Text('No personal details yet',
                style: TextStyle(color: context.appColors.muted)),
        ],
      );
    });
  }
}

class _WorkBlock extends StatelessWidget {
  const _WorkBlock({required this.controller});
  final EditProfileController controller;

  Future<void> _open(BuildContext context, {int? index}) async {
    final result = await showWorkSheet(
      context,
      existing: index == null ? null : controller.workEntries[index],
    );
    if (result == null) return;
    if (result.deleted) {
      if (index != null) {
        controller.workEntries.removeAt(index);
        controller.workEntries.refresh();
      }
      return;
    }
    final value = result.value;
    if (value == null) return;
    if (index != null) {
      controller.workEntries[index] = value;
      controller.workEntries.refresh();
    } else {
      controller.workEntries.add(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.workEntries;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileSectionAddHeader(title: 'Work', onAdd: () => _open(context)),
          if (list.isEmpty)
            Text('No work yet',
                style: TextStyle(color: context.appColors.muted))
          else
            for (var i = 0; i < list.length; i++)
              _TappableRow(
                icon: LucideIcons.building2,
                text: list[i].displayLabel,
                onTap: () => _open(context, index: i),
              ),
        ],
      );
    });
  }
}

class _EducationBlock extends StatelessWidget {
  const _EducationBlock({required this.controller});
  final EditProfileController controller;

  Future<void> _open(BuildContext context, {int? index}) async {
    final result = await showEducationSheet(
      context,
      existing: index == null ? null : controller.educationEntries[index],
    );
    if (result == null) return;
    if (result.deleted) {
      if (index != null) {
        controller.educationEntries.removeAt(index);
        controller.educationEntries.refresh();
      }
      return;
    }
    final value = result.value;
    if (value == null) return;
    if (index != null) {
      controller.educationEntries[index] = value;
      controller.educationEntries.refresh();
    } else {
      controller.educationEntries.add(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.educationEntries;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileSectionAddHeader(
            title: 'Education',
            onAdd: () => _open(context),
          ),
          if (list.isEmpty)
            Text('No education yet',
                style: TextStyle(color: context.appColors.muted))
          else
            for (var i = 0; i < list.length; i++)
              _TappableRow(
                icon: LucideIcons.graduationCap,
                text: list[i].school,
                onTap: () => _open(context, index: i),
              ),
        ],
      );
    });
  }
}

class _LinksBlock extends StatelessWidget {
  const _LinksBlock({required this.controller});
  final EditProfileController controller;

  Future<void> _open(BuildContext context, {int? index}) async {
    final result = await showLinkSheet(
      context,
      existing: index == null ? null : controller.linkEntries[index],
    );
    if (result == null) return;
    if (result.deleted) {
      if (index != null) {
        controller.linkEntries.removeAt(index);
        controller.linkEntries.refresh();
      }
      return;
    }
    final value = result.value;
    if (value == null) return;
    if (index != null) {
      controller.linkEntries[index] = value;
      controller.linkEntries.refresh();
    } else {
      controller.linkEntries.add(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.linkEntries;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileSectionAddHeader(title: 'Links', onAdd: () => _open(context)),
          if (list.isEmpty)
            Text('No links yet',
                style: TextStyle(color: context.appColors.muted))
          else
            for (var i = 0; i < list.length; i++)
              _TappableRow(
                icon: LucideIcons.link,
                text: '${list[i].platform}: ${list[i].url}',
                onTap: () => _open(context, index: i),
              ),
        ],
      );
    });
  }
}

class _ContactBlock extends StatelessWidget {
  const _ContactBlock({required this.controller});
  final EditProfileController controller;

  Future<void> _open(BuildContext context, {int? index}) async {
    final result = await showContactSheet(
      context,
      existing: index == null ? null : controller.contactEntries[index],
    );
    if (result == null) return;
    if (result.deleted) {
      if (index != null) {
        controller.contactEntries.removeAt(index);
        controller.contactEntries.refresh();
      }
      return;
    }
    final value = result.value;
    if (value == null) return;
    if (index != null) {
      controller.contactEntries[index] = value;
      controller.contactEntries.refresh();
    } else {
      controller.contactEntries.add(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.contactEntries;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileSectionAddHeader(
            title: 'Contact info',
            onAdd: () => _open(context),
          ),
          if (list.isEmpty)
            Text('No contact info yet',
                style: TextStyle(color: context.appColors.muted))
          else
            for (var i = 0; i < list.length; i++) ...[
              if (list[i].phone != null && list[i].phone!.trim().isNotEmpty)
                _TappableRow(
                  icon: LucideIcons.phone,
                  text: list[i].phone!,
                  onTap: () => _open(context, index: i),
                ),
              if (list[i].email != null && list[i].email!.trim().isNotEmpty)
                _TappableRow(
                  icon: LucideIcons.mail,
                  text: list[i].email!,
                  onTap: () => _open(context, index: i),
                ),
            ],
        ],
      );
    });
  }
}

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EditProfileController(Get.find<ProfileRepository>()));
  }
}
