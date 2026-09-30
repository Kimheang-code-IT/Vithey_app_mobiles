import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/alerts/in_app_alert_service.dart';
import 'package:aub_connect_app/core/config/app_config.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/network/api_service.dart';
import 'package:aub_connect_app/core/network/dio_client.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/core/storage/secure_storage_service.dart';
import 'package:aub_connect_app/core/theme/app_theme.dart';
import 'package:aub_connect_app/data/local/isar/isar_service.dart';
import 'package:aub_connect_app/data/local/search_recent_store.dart';
import 'package:aub_connect_app/data/push/fcm_service.dart';
import 'package:aub_connect_app/data/repositories/ai_repository.dart';
import 'package:aub_connect_app/data/repositories/auth_repository.dart';
import 'package:aub_connect_app/data/repositories/chat_repository.dart';
import 'package:aub_connect_app/data/repositories/comment_repository.dart';
import 'package:aub_connect_app/data/repositories/cv_repository.dart';
import 'package:aub_connect_app/data/repositories/finance_repository.dart';
import 'package:aub_connect_app/data/repositories/job_application_repository.dart';
import 'package:aub_connect_app/data/repositories/notification_repository.dart';
import 'package:aub_connect_app/data/repositories/place_repository.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:aub_connect_app/data/repositories/search_repository.dart';
import 'package:aub_connect_app/data/repositories/settings_repository.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';
import 'package:aub_connect_app/data/services/ai_service.dart';
import 'package:aub_connect_app/data/services/auth_service.dart';
import 'package:aub_connect_app/data/services/chat_realtime_hub.dart';
import 'package:aub_connect_app/data/services/chat_service.dart';
import 'package:aub_connect_app/data/services/chat_stomp_service.dart';
import 'package:aub_connect_app/data/services/finance_service.dart';
import 'package:aub_connect_app/data/services/google_auth_service.dart';
import 'package:aub_connect_app/data/services/job_application_service.dart';
import 'package:aub_connect_app/data/services/notification_service.dart';
import 'package:aub_connect_app/data/services/place_service.dart';
import 'package:aub_connect_app/data/services/post_search_service.dart';
import 'package:aub_connect_app/data/services/post_service.dart';
import 'package:aub_connect_app/data/services/profile_service.dart';
import 'package:aub_connect_app/data/services/settings_service.dart';
import 'package:aub_connect_app/data/services/student_verification_service.dart';
import 'package:aub_connect_app/data/services/upload_service.dart';
import 'package:aub_connect_app/data/services/user_search_service.dart';

/// Registers all app-wide dependencies (modern stack DI entry point).
class AppBindings {
  static Future<ThemeMode> init() async {
    await AppConfig.init();

    final secureStorage = SecureStorageService();
    final localStorage = LocalStorageService();
    final dioClient = DioClient(secureStorage);
    final featureFlags = FeatureFlags();

    Get.put<FeatureFlags>(featureFlags, permanent: true);
    Get.put<SecureStorageService>(secureStorage, permanent: true);
    Get.put<LocalStorageService>(localStorage, permanent: true);
    Get.put<InAppAlertService>(InAppAlertService(localStorage), permanent: true);
    Get.put<DioClient>(dioClient, permanent: true);
    Get.put<ApiService>(ApiService(dioClient), permanent: true);

    Get.put<AuthService>(AuthService(Get.find<ApiService>()), permanent: true);
    Get.put<GoogleAuthService>(
      GoogleAuthService(serverClientId: AppConfig.instance.googleWebClientId),
      permanent: true,
    );
    Get.put<CurrentUserService>(
      CurrentUserService(secureStorage, Get.find<AuthService>(), featureFlags),
      permanent: true,
    );
    Get.put<AuthRepository>(
      AuthRepository(
        Get.find<AuthService>(),
        Get.find<GoogleAuthService>(),
        secureStorage,
        Get.find<CurrentUserService>(),
        featureFlags,
      ),
      permanent: true,
    );

    Get.put<PostService>(PostService(Get.find<ApiService>()), permanent: true);
    Get.put<PostRepository>(
      PostRepository(
        Get.find<PostService>(),
        Get.find<CurrentUserService>(),
        featureFlags,
        localStorage,
      ),
      permanent: true,
    );
    if (featureFlags.useMockApi) {
      await Get.find<PostRepository>().hydrateMockState(
        restoreCatalogIfNeeded: true,
      );
    }
    Get.put<CommentRepository>(CommentRepository(Get.find<PostRepository>()), permanent: true);
    Get.put<ProfileService>(ProfileService(Get.find<ApiService>()), permanent: true);
    Get.put<UploadService>(UploadService(Get.find<DioClient>()), permanent: true);
    Get.put<JobApplicationService>(JobApplicationService(Get.find<ApiService>()), permanent: true);
    Get.put<CvRepository>(
      CvRepository(Get.find<UploadService>(), Get.find<ApiService>(), featureFlags),
      permanent: true,
    );
    Get.put<JobApplicationRepository>(
      JobApplicationRepository(
        Get.find<PostRepository>(),
        Get.find<JobApplicationService>(),
        featureFlags,
        localStorage,
      ),
      permanent: true,
    );
    if (featureFlags.useMockApi) {
      await Get.find<JobApplicationRepository>().hydrateMockState();
    }
    Get.put<ProfileRepository>(
      ProfileRepository(
        Get.find<ProfileService>(),
        Get.find<PostRepository>(),
        Get.find<JobApplicationRepository>(),
        Get.find<CvRepository>(),
        Get.find<CurrentUserService>(),
        featureFlags,
        localStorage,
      ),
      permanent: true,
    );
    Get.put<StudentVerificationService>(StudentVerificationService(Get.find<ApiService>()), permanent: true);
    // Dev/mock: wipe verification cache each launch so the full flow can be walked.
    if (featureFlags.useMockApi) {
      await localStorage.clearVerificationData();
    }
    Get.put<StudentVerificationRepository>(
      StudentVerificationRepository(
        Get.find<StudentVerificationService>(),
        localStorage,
        featureFlags,
      ),
      permanent: true,
    );
    Get.put<FinanceService>(FinanceService(Get.find<ApiService>()), permanent: true);
    Get.put<FinanceRepository>(
      FinanceRepository(Get.find<FinanceService>(), featureFlags),
      permanent: true,
    );

    final isarService = IsarService();
    await isarService.init();
    Get.put<IsarService>(isarService, permanent: true);
    Get.put<ChatStompService>(ChatStompService(featureFlags), permanent: true);
    final chatRealtimeHub = ChatRealtimeHub(Get.find<ChatStompService>());
    Get.put<ChatRealtimeHub>(chatRealtimeHub, permanent: true);

    Get.put<NotificationService>(NotificationService(Get.find<ApiService>()), permanent: true);
    Get.put<FcmService>(
      FcmService(Get.find<NotificationService>(), featureFlags),
      permanent: true,
    );

    Get.put<ChatService>(ChatService(Get.find<ApiService>()), permanent: true);
    Get.put<ChatRepository>(
      ChatRepository(
        Get.find<ChatService>(),
        Get.find<IsarService>(),
        Get.find<ChatStompService>(),
        featureFlags,
      ),
      permanent: true,
    );
    chatRealtimeHub.onEvent = (payload) => Get.find<ChatRepository>().handleStompPayload(payload);
    chatRealtimeHub.start();
    await Get.find<FcmService>().init();

    Get.put<AiService>(
      AiService(Get.find<ApiService>(), Get.find<DioClient>()),
      permanent: true,
    );
    Get.put<AiRepository>(AiRepository(Get.find<AiService>(), featureFlags), permanent: true);
    Get.put<NotificationRepository>(
      NotificationRepository(Get.find<NotificationService>(), featureFlags),
      permanent: true,
    );
    Get.put<SettingsService>(SettingsService(Get.find<ApiService>()), permanent: true);
    Get.put<SettingsRepository>(
      SettingsRepository(Get.find<SettingsService>(), localStorage, featureFlags),
      permanent: true,
    );
    Get.put<SearchRecentStore>(SearchRecentStore(), permanent: true);
    Get.put<UserSearchService>(UserSearchService(Get.find<ApiService>()), permanent: true);
    Get.put<PostSearchService>(PostSearchService(Get.find<ApiService>()), permanent: true);
    Get.put<SearchRepository>(
      SearchRepository(
        Get.find<UserSearchService>(),
        Get.find<PostSearchService>(),
        Get.find<SearchRecentStore>(),
        featureFlags,
      ),
      permanent: true,
    );
    Get.put<PlaceService>(PlaceService(Get.find<ApiService>()), permanent: true);
    Get.put<PlaceRepository>(
      PlaceRepository(Get.find<PlaceService>(), featureFlags),
      permanent: true,
    );

    await Get.find<CurrentUserService>().restoreSession();

    return AppTheme.fromStorage(await localStorage.readThemeMode());
  }
}
