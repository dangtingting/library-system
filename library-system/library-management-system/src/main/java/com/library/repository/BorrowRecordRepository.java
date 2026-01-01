package com.library.repository;

import com.library.entity.BorrowRecord;
import com.library.entity.User;
import com.library.entity.Book;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface BorrowRecordRepository extends JpaRepository<BorrowRecord, Long> {
    
    List<BorrowRecord> findByUser(User user);
    
    List<BorrowRecord> findByBook(Book book);
    
    List<BorrowRecord> findByStatus(BorrowRecord.BorrowStatus status);
    
    List<BorrowRecord> findByUserAndStatus(User user, BorrowRecord.BorrowStatus status);
    
    List<BorrowRecord> findByDueDateBeforeAndStatus(LocalDate date, BorrowRecord.BorrowStatus status);
    
    @Query("SELECT br FROM BorrowRecord br WHERE br.user.id = :userId AND br.status = :status")
    Page<BorrowRecord> findByUserIdAndStatus(@Param("userId") Long userId, 
                                             @Param("status") BorrowRecord.BorrowStatus status, 
                                             Pageable pageable);
    
    @Query("SELECT br FROM BorrowRecord br WHERE br.dueDate < :currentDate AND br.status = 'BORROWED'")
    List<BorrowRecord> findOverdueRecords(@Param("currentDate") LocalDate currentDate);
    
    @Query("SELECT COUNT(br) FROM BorrowRecord br WHERE br.user = :user AND br.status = 'BORROWED'")
    Integer countBorrowedBooksByUser(@Param("user") User user);
    
    @Query("SELECT br.book, COUNT(br) FROM BorrowRecord br GROUP BY br.book ORDER BY COUNT(br) DESC")
    List<Object[]> findMostPopularBooks(Pageable pageable);
}