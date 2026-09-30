package com.vithey.career.repository;

import com.vithey.career.entity.UserCv;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserCvRepository extends JpaRepository<UserCv, UUID> {
}
