package com.henry.PasswordManagerBackend.Entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(unique = true,nullable = false)
    private String username;

    @Column(nullable = false)
    private String salt;

    @Column(nullable = false)
    private String authHash;

}
