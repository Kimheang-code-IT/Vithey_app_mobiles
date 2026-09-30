package com.vithey.chat.mapper;

import com.vithey.chat.dto.response.MessageResponse;
import com.vithey.chat.dto.response.ReportResponse;
import com.vithey.chat.entity.Message;
import com.vithey.chat.entity.UserReport;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface ChatMapper {

  @Mapping(target = "messageId", source = "id")
  @Mapping(target = "fileUrl", ignore = true)
  MessageResponse toMessageResponse(Message message);

  default MessageResponse toMessageResponse(Message message, String fileUrl) {
    MessageResponse base = toMessageResponse(message);
    return new MessageResponse(
        base.messageId(),
        base.conversationId(),
        base.senderId(),
        base.text(),
        base.messageType(),
        base.fileId(),
        fileUrl,
        base.replyToMessageId(),
        base.status(),
        base.createdAt()
    );
  }

  @Mapping(target = "reportId", source = "id")
  ReportResponse toReportResponse(UserReport report);
}
