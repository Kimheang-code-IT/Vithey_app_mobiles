import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/data/models/finance_dashboard_model.dart';
import 'package:aub_connect_app/modules/home/shell/main_shell_screen.dart';
import 'package:aub_connect_app/core/navigation/main_tab_navigation.dart';
import 'package:aub_connect_app/data/models/student_verification_model.dart';
import 'package:aub_connect_app/data/repositories/finance_repository.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';
import 'package:aub_connect_app/modules/finance/widgets/invoice_preview_sheet.dart';

class FinanceController extends GetxController {
  FinanceController(this._financeRepository, this._verificationRepository);

  final FinanceRepository _financeRepository;
  final StudentVerificationRepository _verificationRepository;

  final dashboard = Rxn<FinanceDashboard>();
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final showAll = false.obs;
  final currentTab = 1.obs;

  final isSearchActive = false.obs;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();
  final searchFocusNode = FocusNode();
  @override
  void onInit() {
    super.onInit();
    _guardAndLoad();
  }

  Future<void> _guardAndLoad() async {
    final verification = await _verificationRepository.getMyVerification();
    if (verification.status != VerificationStatus.verified) {
      final target = verification.status == VerificationStatus.notSubmitted
          ? AppRoutes.studentVerification
          : AppRoutes.verificationStatus;
      Get.offNamed(target);
      return;
    }
    await loadFinanceHome();
  }

  Future<void> loadFinanceHome() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      dashboard.value = await _financeRepository.getFinanceDashboard();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshFinance() async {
    isRefreshing.value = true;
    try {
      dashboard.value = await _financeRepository.getFinanceDashboard();
    } catch (e) {
      Get.snackbar(AppStrings.appName, 'Could not refresh finance data');
    } finally {
      isRefreshing.value = false;
    }
  }

  void toggleShowAll() => showAll.value = !showAll.value;

  void onSearchChanged(String value) => searchQuery.value = value;

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void openSearch() {
    isSearchActive.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isSearchActive.value) searchFocusNode.requestFocus();
    });
  }

  void closeSearch() {
    isSearchActive.value = false;
    clearSearch();
    searchFocusNode.unfocus();
  }

  void toggleSearch() {
    if (isSearchActive.value) {
      closeSearch();
    } else {
      openSearch();
    }
  }

  List<PaymentSummary> get _sortedPayments {
    return List<PaymentSummary>.from(dashboard.value?.payments ?? [])
      ..sort((a, b) => b.sortDate.compareTo(a.sortDate));
  }

  List<PaymentSummary> get visiblePayments {
    final query = searchQuery.value.trim().toLowerCase();
    var items = _sortedPayments;

    if (query.isNotEmpty) {
      items = items
          .where((p) => p.feeName.toLowerCase().contains(query))
          .toList();
      return items;
    }

    if (showAll.value) return items;
    return items.take(4).toList();
  }

  bool get isFilteringTransactions => searchQuery.value.trim().isNotEmpty;

  @override
  void onClose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }
  Future<void> openPaymentDetail(String paymentId) async {
    try {
      final invoice = await _financeRepository.getPaymentInvoice(paymentId);
      await InvoicePreviewSheet.show(
        invoice: invoice,
        onDownload: () => downloadInvoice(paymentId),
      );
    } catch (e) {
      Get.snackbar(AppStrings.appName, 'Payment no longer available');
    }
  }

  Future<void> payNow() async {
    final id = dashboard.value?.nextDuePaymentId;
    if (id == null) {
      Get.snackbar(AppStrings.appName, 'No outstanding payment to pay');
      return;
    }
    await openPaymentDetail(id);
  }

  Future<void> downloadInvoice(String paymentId) async {
    try {
      await _financeRepository.downloadInvoice(paymentId);
      Get.snackbar(AppStrings.appName, 'Invoice downloaded');
    } catch (e) {
      Get.snackbar(AppStrings.appName, 'Could not download invoice');
    }
  }

  void onTabSelected(int index) {
    currentTab.value = index;
    switch (index) {
      case 0:
        Get.offNamed(AppRoutes.home);
        break;
      case 1:
        break;
      case 2:
        Get.offNamed(AppRoutes.createPost);
        break;
      case 3:
        Get.offNamed(AppRoutes.chat);
        break;
      case 4:
        goToMainTab(MainTabNavigation.profile);
        break;
    }
  }
}
