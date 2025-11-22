package com.henry.PasswordManagerBackend.Controllers;

import com.henry.PasswordManagerBackend.Entities.VaultEntry;
import com.henry.PasswordManagerBackend.Services.VaultService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/vault")
public class VaultController {

    private VaultService vaultService;

    VaultController(VaultService vaultService) {
        this.vaultService = vaultService;
    }

    @PostMapping("/{username}")
    public VaultEntry addVaultEntry (@PathVariable String username, @RequestBody VaultEntry vaultEntry) {
        return vaultService.addVaultEntry(username, vaultEntry);
    }

    @DeleteMapping("/{username}/{id}")
    public void deleteVaultEntry (@PathVariable String username, @PathVariable int id) {
        vaultService.deleteVaultEntry(username, id);
    }

    @GetMapping("/{username}")
    public List<VaultEntry> getVaultEntries(@PathVariable String username){
        return vaultService.getVaultEntries(username);
    }


}
