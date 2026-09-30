package com.vithey.auth.repository;

import com.vithey.auth.entity.User;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, UUID> {

  boolean existsByEmailIgnoreCase(String email);

  boolean existsByPhone(String phone);

  Optional<User> findByEmailIgnoreCaseAndDeletedAtIsNull(String email);

  Optional<User> findByPhoneAndDeletedAtIsNull(String phone);
}
