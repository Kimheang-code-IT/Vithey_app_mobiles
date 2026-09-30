package com.vithey.content.mapper;

import com.vithey.content.dto.response.CommentResponse;
import com.vithey.content.entity.Comment;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface CommentMapper {

  @Mapping(target = "commentId", source = "id")
  @Mapping(target = "author", ignore = true)
  CommentResponse toBaseResponse(Comment comment);
}
