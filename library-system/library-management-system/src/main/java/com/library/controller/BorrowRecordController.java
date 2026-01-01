package com.library.controller;

import com.library.entity.BorrowRecord;
import com.library.entity.User;
import com.library.service.BorrowRecordService;
import com.library.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/borrow-records")
@CrossOrigin(origins = "*")
public class BorrowRecordController {
    
    @Autowired
    private BorrowRecordService borrowRecordService;
    
    @Autowired
    private UserService userService;
    
    @PostMapping("/borrow")
    public ResponseEntity<?> borrowBook(
            @RequestParam Long userId,
            @RequestParam Long bookId) {
        try {
            BorrowRecord record = borrowRecordService.borrowBook(userId, bookId);
            return ResponseEntity.ok(record);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("message", "借阅失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    @PostMapping("/return/{recordId}")
    public ResponseEntity<?> returnBook(@PathVariable Long recordId) {
        try {
            BorrowRecord record = borrowRecordService.returnBook(recordId);
            return ResponseEntity.ok(record);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("message", "归还失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    @PostMapping("/renew/{recordId}")
    public ResponseEntity<?> renewBook(@PathVariable Long recordId) {
        try {
            BorrowRecord record = borrowRecordService.renewBook(recordId);
            return ResponseEntity.ok(record);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("message", "续借失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    @GetMapping
    public ResponseEntity<Page<BorrowRecord>> findAll(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<BorrowRecord> records = borrowRecordService.findAll(pageable);
        return ResponseEntity.ok(records);
    }
    
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<BorrowRecord>> findByUser(@PathVariable Long userId) {
        User user = userService.findById(userId).orElse(null);
        if (user == null) {
            return ResponseEntity.notFound().build();
        }
        List<BorrowRecord> records = borrowRecordService.findByUser(user);
        return ResponseEntity.ok(records);
    }
    
    @GetMapping("/user/{userId}/status/{status}")
    public ResponseEntity<Page<BorrowRecord>> findByUserAndStatus(
            @PathVariable Long userId,
            @PathVariable BorrowRecord.BorrowStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<BorrowRecord> records = borrowRecordService.findByUserIdAndStatus(userId, status, pageable);
        return ResponseEntity.ok(records);
    }
    
    @GetMapping("/status/{status}")
    public ResponseEntity<List<BorrowRecord>> findByStatus(@PathVariable BorrowRecord.BorrowStatus status) {
        List<BorrowRecord> records = borrowRecordService.findByStatus(status);
        return ResponseEntity.ok(records);
    }
    
    @GetMapping("/overdue")
    public ResponseEntity<List<BorrowRecord>> findOverdueRecords() {
        List<BorrowRecord> records = borrowRecordService.findOverdueRecords();
        return ResponseEntity.ok(records);
    }
    
    @PostMapping("/check-overdue")
    public ResponseEntity<Void> checkAndUpdateOverdueRecords() {
        borrowRecordService.checkAndUpdateOverdueRecords();
        return ResponseEntity.ok().build();
    }
}