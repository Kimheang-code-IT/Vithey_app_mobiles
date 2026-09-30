package com.vithey.content.mapper;

import com.vithey.content.dto.response.PostResponse;
import com.vithey.content.entity.Post;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface PostMapper {

  @Mapping(target = "postId", source = "id")
  @Mapping(target = "author", ignore = true)
  @Mapping(target = "mediaUrl", ignore = true)
  @Mapping(target = "jobMeta", ignore = true)
  @Mapping(target = "reactionCount", ignore = true)
  @Mapping(target = "commentCount", ignore = true)
  @Mapping(target = "userReacted", ignore = true)
  PostResponse toBaseResponse(Post post);

  default PostResponse.JobMetaResponse toJobMeta(Post post) {
    if (post.getJobTitle() == null && post.getJobDescription() == null
        && post.getJobRequirement() == null && post.getJobDeadline() == null) {
      return null;
    }
    return new PostResponse.JobMetaResponse(
        post.getJobTitle(),
        post.getJobDescription(),
        post.getJobRequirement(),
        post.getJobDeadline()
    );
  }
}
