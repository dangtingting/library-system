package com.library.service;

import com.library.entity.BorrowRecord;
import com.library.entity.User;
import com.library.entity.Book;
import com.library.repository.BorrowRecordRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
@Transactional
public class BorrowRecordService {
    
    @Autowired
    private BorrowRecordRepository borrowRecordRepository;
    
    @Autowired
    private BookService bookService;
    
    @Autowired
    private UserService userService;
    
    private static final int BORROW_DAYS = 30; // 借阅期限30天
    private static final BigDecimal FINE_PER_DAY = new BigDecimal("0.50"); // 每天罚款0.5元
    private static final int MAX_RENEW_COUNT = 2; // 最大续借次数
    
    public BorrowRecord saveBorrowRecord(BorrowRecord record) {
        return borrowRecordRepository.save(record);
    }
    
    public List<BorrowRecord> findAll() {
        return borrowRecordRepository.findAll();
    }
    
    public Page<BorrowRecord> findAll(Pageable pageable) {
        return borrowRecordRepository.findAll(pageable);
    }
    
    public List<BorrowRecord> findByUser(User user) {
        return borrowRecordRepository.findByUser(user);
    }
    
    public List<BorrowRecord> findByUserAndStatus(User user, BorrowRecord.BorrowStatus status) {
        return borrowRecordRepository.findByUserAndStatus(user, status);
    }
    
    public List<BorrowRecord> findOverdueRecords() {
        return borrowRecordRepository.findOverdueRecords(LocalDate.now());
    }
    
    @Transactional
    public BorrowRecord borrowBook(Long userId, Long bookId) {
        // 检查用户是否可以借阅
        if (!userService.canBorrowMore(userId)) {
            throw new RuntimeException("用户已达到借阅上限或账户被禁用");
        }
        
        // 检查图书是否可借
        if (!bookService.borrowBook(bookId)) {
            throw new RuntimeException("图书已借完或不存在");
        }
        
        // 创建借阅记录
        BorrowRecord record = new BorrowRecord();
        User user = userService.findById(userId).orElseThrow(() -> new RuntimeException("用户不存在"));
        Book book = bookService.findById(bookId).orElseThrow(() -> new RuntimeException("图书不存在"));
        
        record.setUser(user);
        record.setBook(book);
        record.setBorrowDate(LocalDate.now());
        record.setDueDate(LocalDate.now().plusDays(BORROW_DAYS));
        record.setStatus(BorrowRecord.BorrowStatus.BORROWED);
        
        // 更新用户借阅数量
        userService.updateBorrowCount(userId, 1);
        
        return borrowRecordRepository.save(record);
    }
    
    @Transactional
    public BorrowRecord returnBook(Long recordId) {
        BorrowRecord record = borrowRecordRepository.findById(recordId)
                .orElseThrow(() -> new RuntimeException("借阅记录不存在"));
        
        if (record.getStatus() != BorrowRecord.BorrowStatus.BORROWED && 
            record.getStatus() != BorrowRecord.BorrowStatus.OVERDUE) {
            throw new RuntimeException("图书已归还或状态异常");
        }
        
        // 更新图书可借数量
        bookService.returnBook(record.getBook().getId());
        
        // 更新用户借阅数量
        userService.updateBorrowCount(record.getUser().getId(), -1);
        
        // 更新借阅记录
        record.setReturnDate(LocalDate.now());
        record.setStatus(BorrowRecord.BorrowStatus.RETURNED);
        
        // 计算罚款
        if (record.getDueDate().isBefore(LocalDate.now())) {
            long overdueDays = ChronoUnit.DAYS.between(record.getDueDate(), LocalDate.now());
            BigDecimal fine = FINE_PER_DAY.multiply(BigDecimal.valueOf(overdueDays));
            record.setFine(fine);
        }
        
        return borrowRecordRepository.save(record);
    }
    
    @Transactional
    public BorrowRecord renewBook(Long recordId) {
        BorrowRecord record = borrowRecordRepository.findById(recordId)
                .orElseThrow(() -> new RuntimeException("借阅记录不存在"));
        
        if (record.getStatus() != BorrowRecord.BorrowStatus.BORROWED) {
            throw new RuntimeException("只有借阅中的图书可以续借");
        }
        
        if (record.getRenewCount() >= MAX_RENEW_COUNT) {
            throw new RuntimeException("已达到最大续借次数");
        }
        
        // 更新续借信息
        record.setDueDate(record.getDueDate().plusDays(BORROW_DAYS));
        record.setRenewCount(record.getRenewCount() + 1);
        record.setStatus(BorrowRecord.BorrowStatus.RENEWED);
        
        return borrowRecordRepository.save(record);
    }
    
    public void checkAndUpdateOverdueRecords() {
        List<BorrowRecord> overdueRecords = findOverdueRecords();
        for (BorrowRecord record : overdueRecords) {
            if (record.getStatus() == BorrowRecord.BorrowStatus.BORROWED) {
                record.setStatus(BorrowRecord.BorrowStatus.OVERDUE);
                borrowRecordRepository.save(record);
            }
        }
    }

    /**
     * 根据用户ID、状态分页查询借阅记录 —— 给 Controller 用
     */
    public Page<BorrowRecord> findByUserIdAndStatus(Long userId, BorrowRecord.BorrowStatus status, Pageable pageable) {
        // 先简单转调仓库，后续可按需扩展
        return borrowRecordRepository.findByUserIdAndStatus(userId, status, pageable);
    }

    /**
     * 根据状态查询全部借阅记录 —— 给 Controller 用
     */
    public List<BorrowRecord> findByStatus(BorrowRecord.BorrowStatus status) {
        return borrowRecordRepository.findByStatus(status);
    }
}