package com.henry.PasswordManagerBackend.Entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class VaultEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String encryptedData;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
}
