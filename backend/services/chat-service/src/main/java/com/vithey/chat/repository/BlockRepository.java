package com.vithey.chat.repository;

import com.vithey.chat.entity.Block;
import com.vithey.chat.entity.BlockId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface BlockRepository extends JpaRepository<Block, BlockId> {

  @Query("""
      SELECT CASE WHEN COUNT(b) > 0 THEN true ELSE false END FROM Block b
      WHERE (b.id.blockerId = :userA AND b.id.blockedId = :userB)
         OR (b.id.blockerId = :userB AND b.id.blockedId = :userA)
      """)
  boolean existsBlockBetween(@Param("userA") java.util.UUID userA, @Param("userB") java.util.UUID userB);
}
