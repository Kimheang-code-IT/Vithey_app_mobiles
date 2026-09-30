package com.vithey.finance.repository;

import com.vithey.finance.entity.FeeCategory;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FeeCategoryRepository extends JpaRepository<FeeCategory, UUID> {
}
