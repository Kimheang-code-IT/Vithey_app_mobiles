package com.vithey.auth.repository;

import com.vithey.auth.entity.AuthProvider;
import com.vithey.auth.entity.UserExternalIdentity;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserExternalIdentityRepository extends JpaRepository<UserExternalIdentity, UUID> {

  Optional<UserExternalIdentity> findByProviderAndProviderSubject(AuthProvider provider, String providerSubject);

  boolean existsByProviderAndProviderSubject(AuthProvider provider, String providerSubject);
}
