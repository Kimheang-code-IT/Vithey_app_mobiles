package com.vithey.finance.repository;

import com.vithey.finance.entity.PaymentTransaction;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PaymentTransactionRepository extends JpaRepository<PaymentTransaction, UUID> {

  Optional<PaymentTransaction> findByIdempotencyKey(String idempotencyKey);
}
