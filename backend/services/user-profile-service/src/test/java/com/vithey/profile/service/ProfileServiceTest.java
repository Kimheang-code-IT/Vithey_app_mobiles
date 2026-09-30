package com.vithey.profile.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.vithey.profile.dto.request.UpdateProfileRequest;
import com.vithey.profile.dto.response.MeProfileResponse;
import com.vithey.profile.dto.response.ProfileResponse;
import com.vithey.profile.entity.AppLanguage;
import com.vithey.profile.entity.AppTheme;
import com.vithey.profile.entity.FieldVisibility;
import com.vithey.profile.entity.Profile;
import com.vithey.profile.entity.ProfileSkillEntry;
import com.vithey.profile.event.publisher.ProfileEventPublisher;
import com.vithey.profile.exception.ApiException;
import com.vithey.profile.mapper.ProfileMapper;
import com.vithey.profile.mapper.ProfileMapperImpl;
import com.vithey.profile.repository.LanguageThemeProjection;
import com.vithey.profile.repository.ProfileRepository;
import com.vithey.profile.repository.UserSettingsRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.transaction.PlatformTransactionManager;

@ExtendWith(MockitoExtension.class)
class ProfileServiceTest {

  @Mock
  private ProfileRepository profileRepository;

  @Mock
  private UserSettingsRepository userSettingsRepository;

  @Spy
  private ProfileMapper profileMapper = new ProfileMapperImpl();

  @Spy
  private ProfileVisibilityService profileVisibilityService = new ProfileVisibilityService();

  @Mock
  private com.vithey.profile.client.FileServiceClient fileServiceClient;

  @Mock
  private SettingsService settingsService;

  @Mock
  private ProfileEventPublisher profileEventPublisher;

  @Mock
  private PlatformTransactionManager transactionManager;

  @InjectMocks
  private ProfileService profileService;

  @Test
  void getMyProfileReturnsProfileAndSettingsSummary() {
    UUID userId = UUID.randomUUID();
    Profile profile = sampleProfile(userId);

    LanguageThemeProjection languageTheme = new LanguageThemeProjection() {
      @Override
      public AppLanguage getLanguage() {
        return AppLanguage.km;
      }

      @Override
      public AppTheme getTheme() {
        return AppTheme.dark;
      }
    };

    when(profileRepository.findById(userId)).thenReturn(Optional.of(profile));
    when(userSettingsRepository.findLanguageThemeByUserId(userId)).thenReturn(Optional.of(languageTheme));

    MeProfileResponse response = profileService.getMyProfile(userId);

    assertThat(response.userId()).isEqualTo(userId);
    assertThat(response.fullName()).isEqualTo("Jane Doe");
    assertThat(response.skills()).hasSize(1);
    assertThat(response.language()).isEqualTo(AppLanguage.km);
    assertThat(response.theme()).isEqualTo(AppTheme.dark);
  }

  @Test
  void getPublicProfileHidesPrivateContactFields() {
    UUID userId = UUID.randomUUID();
    Profile profile = sampleProfile(userId);
    profile.setPhone("098765432");
    profile.setEmail("jane@example.com");
    profile.setFieldVisibility(Map.of(
        "phone", FieldVisibility.PRIVATE,
        "email", FieldVisibility.PRIVATE
    ));

    when(profileRepository.findById(userId)).thenReturn(Optional.of(profile));

    ProfileResponse response = profileService.getPublicProfile(userId);

    assertThat(response.phone()).isNull();
    assertThat(response.email()).isNull();
    assertThat(response.skills()).hasSize(1);
  }

  @Test
  void updateProfilePublishesEventAndReturnsOwnerView() {
    UUID userId = UUID.randomUUID();
    Profile profile = sampleProfile(userId);
    when(profileRepository.findById(userId)).thenReturn(Optional.of(profile));
    when(profileRepository.save(any(Profile.class))).thenAnswer(invocation -> invocation.getArgument(0));

    ProfileResponse response = profileService.updateProfile(
        userId,
        new UpdateProfileRequest(
            null,
            "New bio",
            null,
            null,
            null,
            null,
            null,
            "Phnom Penh",
            LocalDate.of(2004, 8, 1),
            "Fintech Center",
            null,
            null,
            null,
            null,
            null,
            null
        )
    );

    assertThat(response.bio()).isEqualTo("New bio");
    assertThat(response.location()).isEqualTo("Phnom Penh");
    assertThat(response.workplace()).isEqualTo("Fintech Center");
    verify(profileEventPublisher).publishUpdated(any());
  }

  @Test
  void updateProfileRejectsTooManySkills() {
    UUID userId = UUID.randomUUID();
    Profile profile = sampleProfile(userId);
    when(profileRepository.findById(userId)).thenReturn(Optional.of(profile));

    List<com.vithey.profile.dto.request.SkillRequest> skills = java.util.stream.IntStream.range(0, 13)
        .mapToObj(i -> new com.vithey.profile.dto.request.SkillRequest("Skill " + i, 50))
        .toList();

    assertThatThrownBy(() -> profileService.updateProfile(
        userId,
        new UpdateProfileRequest(null, null, null, null, null, null, null, null, null, null, null, null, null, skills, null, null)
    )).isInstanceOf(ApiException.class);
  }

  private Profile sampleProfile(UUID userId) {
    Profile profile = new Profile();
    profile.setUserId(userId);
    profile.setFullName("Jane Doe");
    profile.setBio("Bio");
    profile.setSkills(List.of(new ProfileSkillEntry("Flutter", 75)));
    profile.setEducation(List.of("ACLEDA University"));
    profile.setFieldVisibility(Map.of("phone", FieldVisibility.PRIVATE));
    return profile;
  }
}