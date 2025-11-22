package com.henry.PasswordManagerBackend.Controllers;

import com.henry.PasswordManagerBackend.Entities.User;
import com.henry.PasswordManagerBackend.Services.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/users")
public class UserController {

    private final UserService userService;

    UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/register")
    public User registerUser(@RequestBody User user) {
        return userService.registerUser(user);
    }

    @GetMapping("/{userName}/salt")
    public String getSalt(@PathVariable String userName) {
        return userService.getSalt(userName);
    }

    @PostMapping("/login")
    public ResponseEntity<User> login(@RequestBody User user) {
        try{
            User user1 = userService.login(user.getUsername(),user.getAuthHash());
            return ResponseEntity.ok(user1);
        }
        catch(UsernameNotFoundException|BadCredentialsException e){
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        catch(RuntimeException e){
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
