package com.henry.PasswordManagerBackend.Services;

import com.henry.PasswordManagerBackend.Entities.User;
import com.henry.PasswordManagerBackend.Entities.VaultEntry;
import com.henry.PasswordManagerBackend.Repositories.UserRepository;
import com.henry.PasswordManagerBackend.Repositories.VaultRepository;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;


@Service
public class VaultService {
    VaultRepository vaultRepository;
    UserRepository userRepository;

    public VaultService(VaultRepository vaultRepository, UserRepository userRepository) {
        this.vaultRepository = vaultRepository;
        this.userRepository = userRepository;
    }

    public VaultEntry addVaultEntry (String username, VaultEntry vaultEntry){
        User user = userRepository.findByUsername(username);
        if(user == null){
            throw new UsernameNotFoundException("Username not found");
        }
        vaultEntry.setUser(user);
        return vaultRepository.save(vaultEntry);
    }

    public void deleteVaultEntry (String username, int id){
        vaultRepository.deleteById(id);
    }

    public List<VaultEntry> getVaultEntries(String username) {
        return vaultRepository.findByUserUsername(username);
    }
}
