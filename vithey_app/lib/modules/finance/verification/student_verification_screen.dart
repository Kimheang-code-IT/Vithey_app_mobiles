import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/widgets/custom_text_field.dart';
import 'package:aub_connect_app/core/widgets/form_error_host.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';
import 'package:aub_connect_app/modules/finance/verification/widgets/student_id_upload_box.dart';
import 'package:aub_connect_app/modules/finance/verification/widgets/verification_app_bar.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class StudentVerificationController extends GetxController {
  StudentVerificationController(this._repository);

  final StudentVerificationRepository _repository;

  final studentIdController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final selectedDocumentName = RxnString();
  final selectedDocumentSizeBytes = RxnInt();
  String? _selectedDocumentPath;
  final isSubmitting = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _prefillFromStatus();
  }

  Future<void> _prefillFromStatus() async {
    final current = await _repository.getMyVerification();
    if (current.studentId != null) studentIdController.text = current.studentId!;
    if (current.universityEmail != null) {
      emailController.text = current.universityEmail!;
    }
    if (current.documentFileName != null) {
      selectedDocumentName.value = current.documentFileName;
    }
  }

  void clearFieldErrors() {
    errorMessage.value = '';
    FormErrorHost.clearAll();
  }

  Future<void> pickDocument() async {
    clearFieldErrors();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    _selectedDocumentPath = file.path;
    selectedDocumentName.value = file.name;
    selectedDocumentSizeBytes.value = file.size;
  }

  void removeDocument() {
    clearFieldErrors();
    _selectedDocumentPath = null;
    selectedDocumentName.value = null;
    selectedDocumentSizeBytes.value = null;
    // Drop cached upload so a later resolve cannot reuse the old file.
    unawaited(_repository.clearStoredDocument());
  }

  Future<void> submit() async {
    FormErrorHost.activateFor(formKey);
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (isSubmitting.value) return;

    final hasId = studentIdController.text.trim().isNotEmpty;
    final hasEmail = emailController.text.trim().isNotEmpty;
    final hasDocument = selectedDocumentName.value != null &&
        selectedDocumentName.value!.trim().isNotEmpty;

    if (!hasId || !hasEmail) {
      errorMessage.value = 'Please fill in your student information.';
      return;
    }

    isSubmitting.value = true;
    errorMessage.value = '';
    try {
      // Always re-run verification — never skip because of a previous success.
      await _repository.submitVerification(
        studentId: studentIdController.text.trim(),
        universityEmail: emailController.text.trim(),
        documentFileName: hasDocument ? selectedDocumentName.value : null,
        documentPath: hasDocument ? _selectedDocumentPath : null,
      );
      Get.offNamed(AppRoutes.verificationStatus);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isSubmitting.value = false;
    }
  }

  String? validateStudentId(String? value) =>
      _repository.validateStudentId(value ?? '');

  String? validateEmail(String? value) =>
      _repository.validateUniversityEmail(value ?? '');

  @override
  void onClose() {
    studentIdController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

class StudentVerificationScreen extends GetView<StudentVerificationController> {
  const StudentVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VerificationAppBar(),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          controller.clearFieldErrors();
        },
        child: SafeArea(
          child: FormErrorHost(
            formKey: controller.formKey,
            child: Form(
              key: controller.formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                children: [
                  CustomTextField(
                    controller: controller.studentIdController,
                    label: 'Student ID',
                    hint: 'Enter your Student ID',
                    prefixIcon: LucideIcons.user,
                    textInputAction: TextInputAction.next,
                    validator: controller.validateStudentId,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: controller.emailController,
                    label: 'Student Email',
                    hint: 'your.email@university',
                    prefixIcon: LucideIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: controller.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: controller.passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    prefixIcon: LucideIcons.lock,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => StudentIdUploadBox(
                      fileName: controller.selectedDocumentName.value,
                      fileSizeBytes: controller.selectedDocumentSizeBytes.value,
                      onPick: controller.pickDocument,
                      onRemove: controller.removeDocument,
                    ),
                  ),
                  Obx(() {
                    final error = controller.errorMessage.value;
                    if (error.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        error,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  Obx(
                    () => CustomButton(
                      label: 'Verify Student Status',
                      icon: LucideIcons.shieldCheck,
                      isLoading: controller.isSubmitting.value,
                      onPressed: controller.isSubmitting.value
                          ? null
                          : controller.submit,
                    ),
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
