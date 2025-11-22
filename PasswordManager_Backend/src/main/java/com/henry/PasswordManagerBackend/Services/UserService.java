package com.henry.PasswordManagerBackend.Services;

import com.henry.PasswordManagerBackend.Entities.User;
import com.henry.PasswordManagerBackend.Repositories.UserRepository;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    final UserRepository userRepository;

    UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User registerUser(User newUser) {
        if (userRepository.findByUsername(newUser.getUsername()) != null) {
            throw new RuntimeException("Username already exists");
        }
        return userRepository.save(newUser);
    }

    public String getSalt(String userName) {
        User user = userRepository.findByUsername(userName);
        if (user == null) {
            throw new RuntimeException("User not found");
        }
        return user.getSalt();
    }

    public User login(String username, String authHash) {
        User user = userRepository.findByUsername(username);
        if (user == null) {
            throw new UsernameNotFoundException("Authentication Failed");
        }
        if (!user.getAuthHash().equals(authHash)) {
            throw new BadCredentialsException("Authentication Failed");
        }
        return user;
    }
}
