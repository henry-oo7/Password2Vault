package com.henry.PasswordManagerBackend.Config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;

/*
This http security class is the bouncer for our vault, it handles any incoming traffic and decides what to do with it.
 */

@Configuration
public class SecurityConfig {

    /*
    By default, Spring security blocks everyone.
    This method hands the bouncer a specific checklist of whom to let in and what ID to check
     */
    @Bean //Annotation tells Spring boot to execute this method once and keep the result in memory
          //why we need -- without this, spring security would never see our new rules and would keep using its default paranoid settings
    public SecurityFilterChain securityFilterChain(HttpSecurity http /*This is the builder object. It allows us to chain settings together and builds the security wall for us*/) throws Exception {
        return http
                .csrf(AbstractHttpConfigurer::disable) //by default Spring expects a special token from web requests everytime just to make sure its safe
                                                       //We disable it since our chrome extensions and IOS app dont send these special tokens
                .authorizeHttpRequests(authorize ->authorize.requestMatchers("/**").permitAll())
                .build();
    }
}
