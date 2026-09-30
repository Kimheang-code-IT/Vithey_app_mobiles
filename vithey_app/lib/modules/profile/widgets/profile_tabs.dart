import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/jobs/models/application_status_args.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/core/widgets/status_badge.dart';
import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/modules/home/widgets/poster_post_card.dart';
import 'package:aub_connect_app/modules/profile/profile_tabs_host.dart';
import 'package:aub_connect_app/modules/profile/profile_controller.dart';
import 'package:aub_connect_app/modules/profile/profile_view_controller.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_job_card.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_post_insights_bar.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class ProfilePostersTab extends StatelessWidget {
  const ProfilePostersTab({super.key, this.host});

  final ProfileTabsHost? host;

  @override
  Widget build(BuildContext context) =>
      _ProfilePostsTab(type: PostType.poster, host: host);
}

class ProfileJobsTab extends StatelessWidget {
  const ProfileJobsTab({super.key, this.host});

  final ProfileTabsHost? host;

  @override
  Widget build(BuildContext context) =>
      _ProfilePostsTab(type: PostType.job, host: host);
}

class ProfileAppliedJobsTab extends StatelessWidget {
  const ProfileAppliedJobsTab({super.key, this.viewController});

  /// When set, shows applied jobs for a visitor profile (e.g. Heng Liza).
  final ProfileViewController? viewController;

  @override
  Widget build(BuildContext context) {
    if (viewController != null) {
      return Obx(() {
        final controller = viewController!;
        if (controller.appliedJobsLoading.value &&
            controller.appliedJobs.isEmpty) {
          return const LoadingWidget();
        }
        if (controller.appliedJobs.isEmpty) {
          return const EmptyStateWidget(
            icon: LucideIcons.fileText,
            title: 'No apply job history',
            subtitle: 'No apply job history yet.',
          );
        }
        return _AppliedJobsList(jobs: controller.appliedJobs);
      });
    }

    final controller = Get.find<ProfileController>();
    return Obx(() {
      if (controller.appliedJobsLoading.value &&
          controller.appliedJobs.isEmpty) {
        return const LoadingWidget();
      }
      if (controller.appliedJobs.isEmpty) {
        return const EmptyStateWidget(
          icon: LucideIcons.fileText,
          title: 'No apply job history',
          subtitle: "You don't have any apply job history.",
        );
      }
      return _AppliedJobsList(jobs: controller.appliedJobs);
    });
  }
}

class _AppliedJobsList extends StatelessWidget {
  const _AppliedJobsList({required this.jobs});

  final List<AppliedJobSummary> jobs;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return VitheyCard(
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.symmetric(vertical: 6),
          bordered: true,
          elevated: false,
          borderRadius: VitheyRadii.card,
          clipBehavior: Clip.antiAlias,
          onTap: () => Get.toNamed(
            AppRoutes.applicationStatus,
            arguments: ApplicationStatusArgs(
              applicationId: job.id,
              jobPostId: job.jobPostId,
            ),
          ),
          child: ListTile(
            title: Text(
              job.jobTitle,
              style: context.text.titleMedium,
            ),
            subtitle: Text(
              '${job.company} · ${RelativeTime.format(job.appliedAt)}',
            ),
            trailing: _StatusPill(status: job.status),
          ),
        );
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    // Shared GenZ StatusBadge chrome (pill r20, tinted surface).
    final (label, color) = switch (status) {
      ApplicationStatus.pending => ('Pending', AppColors.pending),
      ApplicationStatus.reviewed => ('Review', AppColors.info),
      ApplicationStatus.accepted => ('Accepted', AppColors.success),
      ApplicationStatus.rejected => ('Rejected', AppColors.error),
    };
    return StatusBadge(label: label, color: color);
  }
}

class _ProfilePostsTab extends StatelessWidget {
  const _ProfilePostsTab({required this.type, this.host});

  final PostType type;
  final ProfileTabsHost? host;

  @override
  Widget build(BuildContext context) {
    final controller = resolveProfileTabsHost(host);
    return Obx(() {
      if (controller.tabLoading[type]!.value &&
          controller.tabPosts[type]!.isEmpty) {
        return const LoadingWidget();
      }
      final posts = controller.tabPosts[type]!;
      if (posts.isEmpty) {
        return EmptyStateWidget(
          title: 'Nothing here yet',
          subtitle: controller.isOwnProfile
              ? 'Create your first ${_label(type)}'
              : 'No ${_label(type)} yet',
        );
      }

      if (type == PostType.job) {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          itemCount: posts.length,
          itemBuilder: (_, index) {
            final post = posts[index];
            return ProfileJobCard(
              post: post,
              isOwnProfile: controller.isOwnProfile,
              onOpenApplicants: () => controller.openJobApplicants(post),
              onApply: () => controller.applyToJob(post.id),
              onOpenPost: () => controller.openPost(post.id),
              onEdit: () => controller.editJobPost(post),
              onDelete: () => controller.deleteJobPost(context, post),
            );
          },
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: posts.length,
        itemBuilder: (_, index) {
          final post = posts[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PosterPostCard(
                post: post,
                // ListView already pads 20 — avoid PostCard's extra horizontal margin.
                margin: const EdgeInsets.symmetric(vertical: 5),
                showShareAction: false,
                onLike: () {},
                onComment: () {},
                onShare: () {},
                onFollow: () {},
                onOpen: () => controller.openPost(post.id),
                onEdit: () => controller.editPost(post),
                onDelete: () => controller.deletePost(context, post),
              ),
              if (controller.isOwnProfile) ...[
                ProfilePostInsightsBar(
                  post: post,
                  onTap: () => controller.openPostAnalytics(post),
                ),
                const SizedBox(height: 8),
              ],
            ],
          );
        },
      );
    });
  }

  String _label(PostType type) {
    return switch (type) {
      PostType.poster => 'poster',
      PostType.job => 'job',
      PostType.video => 'reels',
    };
  }
}
