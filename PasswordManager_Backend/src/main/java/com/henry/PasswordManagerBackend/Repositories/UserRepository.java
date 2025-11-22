package com.henry.PasswordManagerBackend.Repositories;

import com.henry.PasswordManagerBackend.Entities.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Integer> {

    public User findByUsername(String username);
}
