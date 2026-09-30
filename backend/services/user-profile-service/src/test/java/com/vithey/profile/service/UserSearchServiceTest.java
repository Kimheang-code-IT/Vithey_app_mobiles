package com.vithey.profile.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.vithey.profile.dto.response.UserSearchResultResponse;
import com.vithey.profile.repository.ProfileRepository;
import com.vithey.profile.repository.UserSearchProjection;
import com.vithey.profile.util.ApiResponseWrapper;
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

@ExtendWith(MockitoExtension.class)
class UserSearchServiceTest {

  @Mock
  private ProfileRepository profileRepository;

  @InjectMocks
  private UserSearchService userSearchService;

  @Test
  void blankSearchReturnsEmptyPageWithoutQuery() {
    ApiResponseWrapper<List<UserSearchResultResponse>> response =
        userSearchService.search("   ", 1, 20);

    assertThat(response.data()).isEmpty();
    assertThat(response.meta().total()).isZero();
    org.mockito.Mockito.verifyNoInteractions(profileRepository);
  }

  @Test
  void searchShorterThanTwoCharsReturnsEmptyPage() {
    ApiResponseWrapper<List<UserSearchResultResponse>> response =
        userSearchService.search("j", 1, 20);

    assertThat(response.data()).isEmpty();
    org.mockito.Mockito.verifyNoInteractions(profileRepository);
  }

  @Test
  void searchEscapesLikeWildcardsAndMatchesProjection() {
    UUID userId = UUID.randomUUID();
    when(profileRepository.searchByFullName(anyString(), any(Pageable.class)))
        .thenReturn(new PageImpl<>(List.of(row(userId)), PageRequest.of(0, 20), 1));

    ApiResponseWrapper<List<UserSearchResultResponse>> response =
        userSearchService.search("liz_a%50", 1, 20);

    verify(profileRepository).searchByFullName(
        argThat((String query) -> query.equals("liz\\_a\\%50")),
        any(Pageable.class));
    assertThat(response.data()).hasSize(1);
    assertThat(response.data().get(0).userId()).isEqualTo(userId);
    // headline computed from workplace when present
    assertThat(response.data().get(0).headline()).isEqualTo("Fintech Center");
    assertThat(response.meta().page()).isEqualTo(1);
    assertThat(response.meta().limit()).isEqualTo(20);
    assertThat(response.meta().total()).isEqualTo(1);
    assertThat(response.meta().totalPages()).isEqualTo(1);
  }

  @Test
  void headlineFallsBackToMajorAndUniversity() {
    UUID userId = UUID.randomUUID();
    when(profileRepository.searchByFullName(anyString(), any(Pageable.class)))
        .thenReturn(new PageImpl<>(List.of(new UserSearchProjection() {
          @Override public UUID getUserId() { return userId; }
          @Override public String getFullName() { return "Heng Liza"; }
          @Override public String getAvatarUrl() { return null; }
          @Override public String getUniversity() { return "AUB"; }
          @Override public String getMajor() { return "CS"; }
          @Override public String getWorkplace() { return null; }
        }), PageRequest.of(0, 20), 1));

    ApiResponseWrapper<List<UserSearchResultResponse>> response =
        userSearchService.search("heng", 1, 20);

    assertThat(response.data().get(0).headline()).isEqualTo("CS · AUB");
  }

  @Test
  void pageAndLimitAreCapped() {
    when(profileRepository.searchByFullName(anyString(), any(Pageable.class)))
        .thenReturn(new PageImpl<>(List.of(), PageRequest.of(99, 50), 0));

    ApiResponseWrapper<List<UserSearchResultResponse>> response =
        userSearchService.search("jane", 500, 1000);

    verify(profileRepository).searchByFullName(anyString(), argThat((Pageable pageable) ->
        pageable.getPageNumber() == 99 && pageable.getPageSize() == 50));
    assertThat(response.meta().page()).isEqualTo(100);
    assertThat(response.meta().limit()).isEqualTo(50);
  }

  private UserSearchProjection row(UUID userId) {
    return new UserSearchProjection() {
      @Override public UUID getUserId() { return userId; }
      @Override public String getFullName() { return "Heng Liza"; }
      @Override public String getAvatarUrl() { return "https://minio/avatar.jpg"; }
      @Override public String getUniversity() { return "AUB"; }
      @Override public String getMajor() { return "CS"; }
      @Override public String getWorkplace() { return "Fintech Center"; }
    };
  }
}
