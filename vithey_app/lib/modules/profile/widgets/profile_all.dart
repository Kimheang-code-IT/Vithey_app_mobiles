import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/modules/home/widgets/poster_post_card.dart';
import 'package:aub_connect_app/modules/profile/profile_tabs_host.dart';
import 'package:aub_connect_app/modules/profile/profile_controller.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_cv_ai_entry.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_section_sheets.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_skills.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_reels_card.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_post_insights_bar.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class ProfileAllTab extends StatelessWidget {
  const ProfileAllTab({super.key, this.host});

  final ProfileTabsHost? host;

  Future<void> _openSkillSheet(
    BuildContext context,
    ProfileController controller, {
    int? index,
  }) async {
    final current = controller.profile.value;
    if (current == null) return;
    final result = await showSkillSheet(
      context,
      existing: index == null ? null : current.skills[index],
    );
    if (result == null) return;
    final skills = List<ProfileSkill>.from(current.skills);
    if (result.deleted) {
      if (index != null) {
        skills.removeAt(index);
        await controller.saveSkills(skills);
      }
      return;
    }
    final skill = result.value;
    if (skill == null) return;
    if (index != null) {
      skills[index] = skill;
    } else {
      skills.add(skill);
    }
    await controller.saveSkills(skills);
  }

  @override
  Widget build(BuildContext context) {
    final controller = resolveProfileTabsHost(host);
    return Obx(() {
      final profile = controller.profile.value;
      if (profile == null) return const LoadingWidget();
      final ownController =
          controller is ProfileController ? controller : null;
      final canEdit = ownController != null;
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          ProfileSkillsRow(
            skills: profile.skills,
            canEdit: canEdit,
            onAdd: ownController == null
                ? null
                : () => _openSkillSheet(context, ownController),
            onEdit: ownController == null
                ? null
                : (index) => _openSkillSheet(
                      context,
                      ownController,
                      index: index,
                    ),
          ),
          if (profile.skills.isNotEmpty || canEdit) const SizedBox(height: 20),
          if (canEdit) ...[
            const ProfileCvAiEntry(),
            const SizedBox(height: 20),
          ],
          ProfileAllDetails(
            profile: profile,
            isOwnProfile: controller.isOwnProfile,
          ),
          ProfileAllPostsSection(host: host),
        ],
      );
    });
  }
}

/// All tab: display-only titled sections. Editing is only on Edit personal info.
class ProfileAllDetails extends StatefulWidget {
  const ProfileAllDetails({
    super.key,
    required this.profile,
    required this.isOwnProfile,
  });

  final UserProfileModel profile;
  final bool isOwnProfile;

  /// Rows shown before "Show more" (section titles do not count).
  static const collapsedRowLimit = 5;

  @override
  State<ProfileAllDetails> createState() => _ProfileAllDetailsState();
}

class _ProfileAllDetailsState extends State<ProfileAllDetails> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final personal = <_AllRowData>[
      if (profile.location != null && profile.location!.trim().isNotEmpty)
        _AllRowData(LucideIcons.mapPin, profile.location!),
      if (profile.gender != null && profile.gender!.trim().isNotEmpty)
        _AllRowData(LucideIcons.user, profile.gender!),
      if (profile.dateOfBirth != null)
        _AllRowData(
          LucideIcons.cake,
          DateFormat('MMMM dd yyyy').format(profile.dateOfBirth!),
        ),
      for (final extra in profile.personalExtras)
        if (extra.trim().isNotEmpty)
          _AllRowData(LucideIcons.fileText, extra),
    ];

    final work = <_AllRowData>[
      for (final job in profile.workItems)
        if (job.displayLabel.trim().isNotEmpty)
          _AllRowData(LucideIcons.building2, job.displayLabel),
    ];

    final education = <_AllRowData>[
      for (final edu in profile.educationItems) ...[
        if (edu.school.trim().isNotEmpty)
          _AllRowData(LucideIcons.graduationCap, edu.school),
        if (edu.major != null && edu.major!.trim().isNotEmpty)
          _AllRowData(LucideIcons.bookOpen, edu.major!),
        if (edu.certificate != null && edu.certificate!.trim().isNotEmpty)
          _AllRowData(LucideIcons.award, edu.certificate!),
      ],
    ];

    final links = <_AllLinkData>[
      for (final link in profile.linkItems)
        if (link.url.trim().isNotEmpty)
          _AllLinkData(
            link.platform.trim().isEmpty ? link.url : link.platform,
            link.url,
          ),
    ];

    final contact = <_AllRowData>[
      if (widget.isOwnProfile)
        for (final c in profile.contactItems) ...[
          if (c.phone != null && c.phone!.trim().isNotEmpty)
            _AllRowData(LucideIcons.phone, c.phone!),
          if (c.email != null && c.email!.trim().isNotEmpty)
            _AllRowData(LucideIcons.mail, c.email!),
        ],
    ];

    final sections = <_AllSectionData>[
      if (personal.isNotEmpty)
        _AllSectionData(title: 'Personal details', rows: personal),
      if (work.isNotEmpty) _AllSectionData(title: 'Work', rows: work),
      if (education.isNotEmpty)
        _AllSectionData(title: 'Education', rows: education),
      if (links.isNotEmpty) _AllSectionData.links(links),
      if (contact.isNotEmpty)
        _AllSectionData(title: 'Contact info', rows: contact),
    ];

    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalRows = sections.fold<int>(0, (sum, s) => sum + s.rowCount);
    final canToggle = totalRows > ProfileAllDetails.collapsedRowLimit;
    final visibleSections = (!canToggle || _expanded)
        ? sections
        : _truncateSections(sections, ProfileAllDetails.collapsedRowLimit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < visibleSections.length; i++) ...[
          if (i > 0) const SizedBox(height: 18),
          visibleSections[i].build(context),
        ],
        if (canToggle) ...[
          const SizedBox(height: 8),
          _ShowMoreLessButton(
            expanded: _expanded,
            onTap: () => setState(() => _expanded = !_expanded),
          ),
        ],
        const SizedBox(height: 18),
      ],
    );
  }

  List<_AllSectionData> _truncateSections(
    List<_AllSectionData> sections,
    int rowLimit,
  ) {
    final out = <_AllSectionData>[];
    var remaining = rowLimit;
    for (final section in sections) {
      if (remaining <= 0) break;
      final take = section.takeRows(remaining);
      if (take == null) continue;
      out.add(take);
      remaining -= take.rowCount;
    }
    return out;
  }
}

/// Mixed reels + posters below Contact info — same data as Reels/Posters nav tabs.
class ProfileAllPostsSection extends StatefulWidget {
  const ProfileAllPostsSection({super.key, this.host});

  final ProfileTabsHost? host;

  @override
  State<ProfileAllPostsSection> createState() => _ProfileAllPostsSectionState();
}

class _ProfileAllPostsSectionState extends State<ProfileAllPostsSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resolveProfileTabsHost(widget.host).ensureAllPostsLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = resolveProfileTabsHost(widget.host);
    return Obx(() {
      if (controller.isAllPostsLoading) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: LoadingWidget(),
        );
      }

      final posts = controller.mergedReelsAndPosters;
      if (posts.isEmpty) {
        return EmptyStateWidget(
          title: 'No posts yet',
          subtitle: controller.isOwnProfile
              ? 'Your reels and posters will show here'
              : 'No posts to show',
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Post',
            style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (final post in posts)
            _AllPostTile(host: controller, post: post),
        ],
      );
    });
  }
}

class _AllPostTile extends StatelessWidget {
  const _AllPostTile({required this.host, required this.post});

  final ProfileTabsHost host;
  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final card = post.type == PostType.video
        ? ProfileReelsCard(
            post: post,
            onLike: () {},
            onComment: () => host.openPost(post.id),
            onShare: () {},
          )
        : PosterPostCard(
            post: post,
            margin: const EdgeInsets.symmetric(vertical: 5),
            showShareAction: false,
            onLike: () {},
            onComment: () {},
            onShare: () {},
            onFollow: () {},
            onOpen: () => host.openPost(post.id),
            onEdit: () => host.editPost(post),
            onDelete: () => host.deletePost(context, post),
          );

    if (!host.isOwnProfile) return card;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        card,
        ProfilePostInsightsBar(
          post: post,
          onTap: () => host.openPostAnalytics(post),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _AllRowData {
  const _AllRowData(this.icon, this.text);
  final IconData icon;
  final String text;
}

class _AllLinkData {
  const _AllLinkData(this.label, this.url);
  final String label;
  final String url;
}

class _AllSectionData {
  const _AllSectionData({
    required this.title,
    this.rows = const [],
    this.links = const [],
  });

  factory _AllSectionData.links(List<_AllLinkData> links) =>
      _AllSectionData(title: 'Links', links: links);

  final String title;
  final List<_AllRowData> rows;
  final List<_AllLinkData> links;

  int get rowCount => rows.isNotEmpty ? rows.length : links.length;

  _AllSectionData? takeRows(int count) {
    if (count <= 0 || rowCount == 0) return null;
    if (links.isNotEmpty) {
      return _AllSectionData(
        title: title,
        links: links.take(count).toList(),
      );
    }
    return _AllSectionData(
      title: title,
      rows: rows.take(count).toList(),
    );
  }

  Widget build(BuildContext context) {
    if (links.isNotEmpty) {
      return _AllLinksSection(links: links);
    }
    return _AllSection(title: title, rows: rows);
  }
}

class _ShowMoreLessButton extends StatelessWidget {
  const _ShowMoreLessButton({
    required this.expanded,
    required this.onTap,
  });

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(VitheyRadii.pill),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    expanded ? 'Show less' : 'Show more',
                    style: context.text.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  VitheyIcon(
                    expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    size: 18,
                    color: colors.heading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AllSection extends StatelessWidget {
  const _AllSection({required this.title, required this.rows});

  final String title;
  final List<_AllRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        for (final row in rows) _DetailRow(icon: row.icon, text: row.text),
      ],
    );
  }
}

class _AllLinksSection extends StatelessWidget {
  const _AllLinksSection({required this.links});

  final List<_AllLinkData> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Links',
          style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        for (final link in links)
          _LinkDetailRow(label: link.label, url: link.url),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VitheyIcon(icon, size: 20, color: context.appColors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: context.text.bodyLarge?.copyWith(fontSize: 15, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkDetailRow extends StatelessWidget {
  const _LinkDetailRow({required this.label, required this.url});

  final String label;
  final String url;

  Future<void> _open(BuildContext context) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid link')),
      );
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final showUrlAsLabel = label.startsWith('http');
    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(VitheyRadii.field),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VitheyIcon(LucideIcons.link, size: 20, color: context.appColors.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                showUrlAsLabel ? url : label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyLarge?.copyWith(
                  fontSize: 15,
                  height: 1.35,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
