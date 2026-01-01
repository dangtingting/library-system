package com.library.controller;

import com.library.entity.User;
import com.library.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {
    
    @Autowired
    private UserService userService;
    
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> loginData) {
        String username = loginData.get("username");
        String password = loginData.get("password");
        
        Optional<User> userOpt = userService.findByUsername(username);
        
        if (!userOpt.isPresent()) {
            Map<String, String> error = new HashMap<>();
            error.put("message", "用户不存在");
            return ResponseEntity.status(401).body(error);
        }
        
        User user = userOpt.get();
        
        // 简单的密码验证（实际项目中应该使用加密）
        if (!user.getPassword().equals(password)) {
            Map<String, String> error = new HashMap<>();
            error.put("message", "密码错误");
            return ResponseEntity.status(401).body(error);
        }
        
        if (user.getStatus() == 0) {
            Map<String, String> error = new HashMap<>();
            error.put("message", "账户已被禁用");
            return ResponseEntity.status(401).body(error);
        }
        
        // 返回用户信息（不包含密码）
        Map<String, Object> result = new HashMap<>();
        result.put("id", user.getId());
        result.put("username", user.getUsername());
        result.put("realName", user.getRealName());
        result.put("email", user.getEmail());
        result.put("phone", user.getPhone());
        result.put("userType", user.getUserType());
        result.put("borrowCount", user.getBorrowCount());
        result.put("maxBorrowLimit", user.getMaxBorrowLimit());
        
        return ResponseEntity.ok(result);
    }
    
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody User user) {
        try {
            // 设置默认值为读者
            user.setUserType(User.UserType.READER);
            user.setStatus(1);
            user.setBorrowCount(0);
            user.setMaxBorrowLimit(5);
            
            User savedUser = userService.saveUser(user);
            
            // 返回用户信息（不包含密码）
            Map<String, Object> result = new HashMap<>();
            result.put("id", savedUser.getId());
            result.put("username", savedUser.getUsername());
            result.put("realName", savedUser.getRealName());
            result.put("email", savedUser.getEmail());
            result.put("phone", savedUser.getPhone());
            result.put("userType", savedUser.getUserType());
            
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("message", "注册失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    @PostMapping("/logout")
    public ResponseEntity<Void> logout() {
        // 简单的退出处理
        return ResponseEntity.ok().build();
    }
}