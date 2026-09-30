package com.vithey.career.mapper;

import com.vithey.career.dto.response.JobApplicationResponse;
import com.vithey.career.dto.response.UserCvResponse;
import com.vithey.career.entity.JobApplication;
import com.vithey.career.entity.UserCv;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface JobApplicationMapper {

  @Mapping(target = "applicationId", source = "id")
  @Mapping(target = "applicant", ignore = true)
  @Mapping(target = "cvFileName", ignore = true)
  @Mapping(target = "jobTitle", ignore = true)
  @Mapping(target = "organization", ignore = true)
  JobApplicationResponse toBaseResponse(JobApplication application);

  UserCvResponse toResponse(UserCv userCv);
}
