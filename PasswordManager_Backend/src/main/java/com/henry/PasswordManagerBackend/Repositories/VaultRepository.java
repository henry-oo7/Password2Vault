package com.henry.PasswordManagerBackend.Repositories;

import com.henry.PasswordManagerBackend.Entities.VaultEntry;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface VaultRepository extends JpaRepository<VaultEntry, Integer> {

    List<VaultEntry> findByUserUsername(String userUsername);

}
