package com.vithey.content.repository;

import com.vithey.content.entity.Mention;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MentionRepository extends JpaRepository<Mention, UUID> {

  void deleteByCommentId(UUID commentId);
}
