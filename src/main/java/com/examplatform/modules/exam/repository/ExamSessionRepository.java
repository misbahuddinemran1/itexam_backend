package com.examplatform.modules.exam.repository;

import com.examplatform.modules.exam.entity.ExamSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface ExamSessionRepository extends JpaRepository<ExamSession, String> {

    List<ExamSession> findByUserIdOrderByCreatedAtDesc(String userId);

    Optional<ExamSession> findByIdAndUserId(String id, String userId);

    List<ExamSession> findByUserIdAndSessionTypeOrderByCreatedAtDesc(
            String userId, ExamSession.SessionType sessionType);

    long countByUserIdAndSessionType(String userId, ExamSession.SessionType sessionType);

    long countByCreatedAtAfter(LocalDateTime dateTime);

    long countByCreatedAtBetween(LocalDateTime start, LocalDateTime end);
    long countByUserId(String userId);

    List<ExamSession> findTop5ByOrderByCreatedAtDesc();

}