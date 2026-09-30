package com.vithey.finance.repository;

import com.vithey.finance.entity.StudentFinanceAccount;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StudentFinanceAccountRepository extends JpaRepository<StudentFinanceAccount, UUID> {
}
