import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/data/fixtures/cv_template_fixtures.dart';
import 'package:aub_connect_app/data/models/cv_template.dart';
import 'package:aub_connect_app/modules/jobs/ai_cv/ai_cv_args.dart';
import 'package:aub_connect_app/modules/jobs/models/apply_cv_args.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CvTemplateGalleryController extends GetxController {
  final searchController = TextEditingController();
  final query = ''.obs;
  final category = 'All'.obs;
  final style = 'All'.obs;
  final language = 'All'.obs;

  late final AiCvArgs navArgs;

  @override
  void onInit() {
    super.onInit();
    navArgs = AiCvArgs.from(Get.arguments);
    searchController.addListener(() {
      query.value = searchController.text;
    });
  }

  List<CvTemplate> get filtered => CvTemplateFixtures.filter(
        query: query.value,
        category: category.value,
        style: style.value,
        language: language.value,
      );

  void setCategory(String value) => category.value = value;
  void setStyle(String value) => style.value = value;
  void setLanguage(String value) => language.value = value;

  void openTemplate(CvTemplate template) {
    Get.offNamed(
      AppRoutes.applyCvAiCreate,
      arguments: navArgs.copyWith(
        templateId: template.id,
        blank: false,
      ),
    );
  }

  void openBlank() {
    Get.offNamed(
      AppRoutes.applyCvAiCreate,
      arguments: navArgs.copyWith(
        templateId: CvTemplateFixtures.blank.id,
        blank: true,
      ),
    );
  }

  void cancel() {
    if (!navArgs.hasJobContext) {
      Get.back();
      return;
    }
    Get.offNamed(
      AppRoutes.applyCv,
      arguments: ApplyCvArgs(
        jobPostId: navArgs.jobPostId!,
        jobPreview: navArgs.jobPreview,
      ),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
