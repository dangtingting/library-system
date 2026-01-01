package com.library.service;

import com.library.entity.User;
import com.library.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class UserService {
    
    @Autowired
    private UserRepository userRepository;
    
    public User saveUser(User user) {
        return userRepository.save(user);
    }
    
    public Optional<User> findById(Long id) {
        return userRepository.findById(id);
    }
    
    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }
    
    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }
    
    public List<User> findAll() {
        return userRepository.findAll();
    }
    
    public Page<User> findAll(Pageable pageable) {
        return userRepository.findAll(pageable);
    }
    
    public List<User> findByUserType(User.UserType userType) {
        return userRepository.findByUserType(userType);
    }
    
    public Page<User> searchReaders(String keyword, Pageable pageable) {
        return userRepository.searchUsers(User.UserType.READER, keyword, pageable);
    }
    
    public Page<User> searchAdmins(String keyword, Pageable pageable) {
        return userRepository.searchUsers(User.UserType.ADMIN, keyword, pageable);
    }
    
    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }
    
    public boolean updateBorrowCount(Long userId, int increment) {
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            int newCount = user.getBorrowCount() + increment;
            if (newCount >= 0 && newCount <= user.getMaxBorrowLimit()) {
                user.setBorrowCount(newCount);
                userRepository.save(user);
                return true;
            }
        }
        return false;
    }
    
    public boolean canBorrowMore(Long userId) {
        Optional<User> userOpt = userRepository.findById(userId);
        return userOpt.map(user -> 
            user.getBorrowCount() < user.getMaxBorrowLimit() && user.getStatus() == 1
        ).orElse(false);
    }
}