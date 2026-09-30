package com.vithey.finance.repository;

import com.vithey.finance.entity.Fee;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FeeRepository extends JpaRepository<Fee, UUID> {
}
