package com.vithey.chat.repository;

import com.vithey.chat.entity.UserReport;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserReportRepository extends JpaRepository<UserReport, UUID> {
}
