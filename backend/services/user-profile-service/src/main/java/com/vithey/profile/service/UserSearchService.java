package com.vithey.profile.service;

import com.vithey.profile.dto.response.UserSearchResultResponse;
import com.vithey.profile.repository.ProfileRepository;
import com.vithey.profile.repository.UserSearchProjection;
import com.vithey.profile.util.ApiResponseWrapper;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class UserSearchService {

  private static final int DEFAULT_LIMIT = 20;
  private static final int MAX_LIMIT = 50;
  private static final int MAX_PAGE = 100;
  private static final int MIN_SEARCH_LENGTH = 2;

  private final ProfileRepository profileRepository;

  public UserSearchService(ProfileRepository profileRepository) {
    this.profileRepository = profileRepository;
  }

  @Transactional(readOnly = true)
  public ApiResponseWrapper<List<UserSearchResultResponse>> search(String search, int page, int limit) {
    int safePage = Math.min(Math.max(page, 1), MAX_PAGE);
    int safeLimit = Math.min(Math.max(limit > 0 ? limit : DEFAULT_LIMIT, 1), MAX_LIMIT);

    if (!StringUtils.hasText(search)) {
      return ApiResponseWrapper.paginated(List.of(), new ApiResponseWrapper.Meta(safePage, safeLimit, 0, 0));
    }

    String query = search.trim();
    if (query.length() < MIN_SEARCH_LENGTH) {
      return ApiResponseWrapper.paginated(List.of(), new ApiResponseWrapper.Meta(safePage, safeLimit, 0, 0));
    }

    PageRequest pageable = PageRequest.of(safePage - 1, safeLimit);
    Page<UserSearchProjection> results = profileRepository.searchByFullName(escapeLike(query), pageable);

    List<UserSearchResultResponse> content = results.getContent().stream()
        .map(row -> new UserSearchResultResponse(
            row.getUserId(),
            row.getFullName(),
            row.getAvatarUrl(),
            row.getUniversity(),
            row.getMajor(),
            buildSearchHeadline(row.getWorkplace(), row.getMajor(), row.getUniversity())
        ))
        .toList();

    return ApiResponseWrapper.paginated(
        content,
        new ApiResponseWrapper.Meta(safePage, safeLimit, results.getTotalElements(), results.getTotalPages())
    );
  }

  private static String buildSearchHeadline(String workplace, String major, String university) {
    if (StringUtils.hasText(workplace)) {
      return workplace;
    }
    if (StringUtils.hasText(major) && StringUtils.hasText(university)) {
      return major + " · " + university;
    }
    if (StringUtils.hasText(major)) {
      return major;
    }
    if (StringUtils.hasText(university)) {
      return university;
    }
    return null;
  }

  private static String escapeLike(String value) {
    return value
        .replace("\\", "\\\\")
        .replace("%", "\\%")
        .replace("_", "\\_");
  }
}