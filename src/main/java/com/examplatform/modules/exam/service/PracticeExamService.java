package com.examplatform.modules.exam.service;

import com.examplatform.common.exception.ResourceNotFoundException;
import com.examplatform.common.exception.ValidationException;
import com.examplatform.modules.exam.dto.*;
import com.examplatform.modules.exam.entity.ExamSession;
import com.examplatform.modules.exam.entity.QuestionAttempt;
import com.examplatform.modules.exam.repository.ExamSessionRepository;
import com.examplatform.modules.exam.repository.QuestionAttemptRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PracticeExamService {

    private final ExamSessionRepository examSessionRepository;
    private final QuestionAttemptRepository questionAttemptRepository;
    private final JdbcTemplate jdbcTemplate;

    // ─── Practice Session শুরু করা ────────────────────────────
    @Transactional
    public PracticeSessionResponse startPractice(String userId,
                                                   PracticeStartRequest request) {

        // Validation
        if (request.getSubjectId() == null && request.getTopicId() == null) {
            throw new ValidationException("Subject অথবা Topic দিতে হবে");
        }
        if (request.getQuestionCount() < 1 || request.getQuestionCount() > 50) {
            throw new ValidationException("প্রশ্ন সংখ্যা ১ থেকে ৫০ এর মধ্যে হতে হবে");
        }

        // প্রশ্ন খোঁজা
        List<String> questionIds = fetchQuestionIds(request);
        if (questionIds.isEmpty()) {
            throw new ValidationException("এই বিষয়ে কোনো প্রশ্ন পাওয়া যায়নি");
        }

        // Session তৈরি
        ExamSession session = ExamSession.builder()
        .id(UUID.randomUUID().toString())
        .userId(userId)
        .topicId(request.getTopicId())
        .sessionType(ExamSession.SessionType.PRACTICE)
        .status(ExamSession.Status.IN_PROGRESS)
        .totalQuestions(questionIds.size())
        .attemptedCount(0)
        .correctCount(0)
        .wrongCount(0)
        .skipCount(0)
        .score(0)
        .percentage(0)
        .timeSpentSec(0)
        .isPassed(false)
        .startedAt(LocalDateTime.now())   // ✅ এটা add করো
        .createdAt(LocalDateTime.now())   // ✅ এটা add করো
        .updatedAt(LocalDateTime.now())   // ✅ এটা add করো
        .build();
        examSessionRepository.save(session);
        examSessionRepository.flush();

        // Question order save করা (session এ question list রাখব)
        saveSessionQuestions(session.getId(), questionIds);

        return PracticeSessionResponse.builder()
                .sessionId(session.getId())
                .sessionType("PRACTICE")
                .totalQuestions(session.getTotalQuestions())
                .attemptedCount(0)
                .remainingCount(session.getTotalQuestions())
                .status("IN_PROGRESS")
                .startedAt(session.getStartedAt()
                        .format(DateTimeFormatter.ISO_LOCAL_DATE_TIME))
                .build();
    }

    // ─── পরবর্তী প্রশ্ন নেওয়া ────────────────────────────────
    public QuestionResponse getNextQuestion(String userId, String sessionId) {

        ExamSession session = getSession(userId, sessionId);

        if (session.getStatus() == ExamSession.Status.COMPLETED) {
            throw new ValidationException("এই exam সম্পন্ন হয়ে গেছে");
        }

        // attempted question ids
        List<String> attemptedIds = questionAttemptRepository
                .findBySessionId(sessionId)
                .stream()
                .map(QuestionAttempt::getQuestionId)
                .collect(Collectors.toList());

        // session এর question list থেকে পরবর্তী প্রশ্ন
        List<String> allQuestionIds = getSessionQuestions(sessionId);
        String nextQuestionId = allQuestionIds.stream()
                .filter(id -> !attemptedIds.contains(id))
                .findFirst()
                .orElse(null);

        if (nextQuestionId == null) {
            throw new ValidationException("সব প্রশ্ন শেষ হয়ে গেছে");
        }

        int questionNumber = attemptedIds.size() + 1;

        return buildQuestionResponse(nextQuestionId, questionNumber,
                session.getTotalQuestions());
    }

    // ─── Answer Submit করা ────────────────────────────────────
    @Transactional
    public AnswerResultResponse submitAnswer(String userId, String sessionId,
                                              SubmitAnswerRequest request) {

        ExamSession session = getSession(userId, sessionId);

        if (session.getStatus() == ExamSession.Status.COMPLETED) {
            throw new ValidationException("এই exam সম্পন্ন হয়ে গেছে");
        }

        // Already answered check
        questionAttemptRepository
                .findBySessionIdAndQuestionId(sessionId, request.getQuestionId())
                .ifPresent(a -> {
                    throw new ValidationException("এই প্রশ্নের উত্তর আগেই দেওয়া হয়েছে");
                });

        // Correct answer খোঁজা
        boolean isCorrect = false;
        String correctOptionId = null;
        String explanation = null;
        String explanationBn = null;

        if (!request.isSkipped() && request.getSelectedOptionId() != null) {
            Map<String, Object> correctOption = findCorrectOption(
                    request.getQuestionId());
            if (correctOption != null) {
                correctOptionId = (String) correctOption.get("id");
                explanation = (String) correctOption.get("explanation");
                explanationBn = (String) correctOption.get("explanation_bn");
                isCorrect = correctOptionId.equals(request.getSelectedOptionId());
            }
        } else {
            // Correct option এখনো দরকার explanation এর জন্য
            Map<String, Object> correctOption = findCorrectOption(
                    request.getQuestionId());
            if (correctOption != null) {
                correctOptionId = (String) correctOption.get("id");
                explanation = (String) correctOption.get("explanation");
                explanationBn = (String) correctOption.get("explanation_bn");
            }
        }

        // Attempt save
        QuestionAttempt attempt = QuestionAttempt.builder()
                .id(UUID.randomUUID().toString())
                .sessionId(sessionId)
                .questionId(request.getQuestionId())
                .selectedOptionId(request.getSelectedOptionId())
                .isCorrect(isCorrect)
                .isSkipped(request.isSkipped())
                .timeSpentSec(request.getTimeSpentSec())
                .build();

        questionAttemptRepository.save(attempt);

        // Session update
        session.setAttemptedCount(session.getAttemptedCount() + 1);
        session.setTimeSpentSec(session.getTimeSpentSec() + request.getTimeSpentSec());

        if (request.isSkipped()) {
            session.setSkipCount(session.getSkipCount() + 1);
        } else if (isCorrect) {
            session.setCorrectCount(session.getCorrectCount() + 1);
        } else {
            session.setWrongCount(session.getWrongCount() + 1);
        }

        // সব প্রশ্ন শেষ হলে complete
        if (session.getAttemptedCount() >= session.getTotalQuestions()) {
            completeSession(session);
        }

        examSessionRepository.save(session);

        int remaining = session.getTotalQuestions() - session.getAttemptedCount();

        return AnswerResultResponse.builder()
                .isCorrect(isCorrect)
                .correctOptionId(correctOptionId)
                .explanation(explanation)
                .explanationBn(explanationBn)
                .attemptedCount(session.getAttemptedCount())
                .remainingCount(remaining)
                .build();
    }

    // ─── Result দেখা ──────────────────────────────────────────
    public ExamResultResponse getResult(String userId, String sessionId) {

        ExamSession session = getSession(userId, sessionId);

        List<QuestionAttempt> attempts = questionAttemptRepository
                .findBySessionId(sessionId);

        List<ExamResultResponse.QuestionReviewResponse> reviews =
                attempts.stream().map(attempt -> {
                    Map<String, Object> question = fetchQuestion(attempt.getQuestionId());
                    Map<String, Object> correctOption = findCorrectOption(
                            attempt.getQuestionId());

                    return ExamResultResponse.QuestionReviewResponse.builder()
                            .questionId(attempt.getQuestionId())
                            .questionText(question != null ?
                                    (String) question.get("question_text") : "")
                            .selectedOptionId(attempt.getSelectedOptionId())
                            .correctOptionId(correctOption != null ?
                                    (String) correctOption.get("id") : "")
                            .isCorrect(attempt.isCorrect())
                            .isSkipped(attempt.isSkipped())
                            .explanation(correctOption != null ?
                                    (String) correctOption.get("explanation") : "")
                            .build();
                }).collect(Collectors.toList());

        return ExamResultResponse.builder()
                .sessionId(session.getId())
                .sessionType(session.getSessionType().name())
                .totalQuestions(session.getTotalQuestions())
                .attemptedCount(session.getAttemptedCount())
                .correctCount(session.getCorrectCount())
                .wrongCount(session.getWrongCount())
                .skipCount(session.getSkipCount())
                .score(session.getScore())
                .percentage(session.getPercentage())
                .timeSpentSec(session.getTimeSpentSec())
                .isPassed(session.isPassed())
                .questionReviews(reviews)
                .build();
    }

    // ─── Helper Methods ───────────────────────────────────────
    private ExamSession getSession(String userId, String sessionId) {
        return examSessionRepository.findByIdAndUserId(sessionId, userId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Exam session পাওয়া যায়নি"));
    }

    private void completeSession(ExamSession session) {
        double percentage = session.getTotalQuestions() > 0
                ? (session.getCorrectCount() * 100.0) / session.getTotalQuestions()
                : 0;
        session.setPercentage(percentage);
        session.setScore(session.getCorrectCount());
        session.setPassed(percentage >= 40);
        session.setStatus(ExamSession.Status.COMPLETED);
        session.setCompletedAt(LocalDateTime.now());
    }

    private List<String> fetchQuestionIds(PracticeStartRequest request) {
        StringBuilder sql = new StringBuilder(
                "SELECT id FROM questions WHERE status = 'APPROVED'");
        List<Object> params = new ArrayList<>();

        if (request.getSubjectId() != null) {
            sql.append(" AND subject_id = ?");
            params.add(request.getSubjectId());
        }
        if (request.getTopicId() != null) {
            sql.append(" AND topic_id = ?");
            params.add(request.getTopicId());
        }
        if (request.getChapterId() != null) {
            sql.append(" AND chapter_id = ?");
            params.add(request.getChapterId());
        }
        if (request.getDifficultyLevel() != null) {
            sql.append(" AND difficulty_level = ?");
            params.add(request.getDifficultyLevel());
        }

        sql.append(" ORDER BY RAND() LIMIT ?");
        params.add(request.getQuestionCount());

        return jdbcTemplate.queryForList(sql.toString(), String.class,
                params.toArray());
    }

    private void saveSessionQuestions(String sessionId, List<String> questionIds) {
        // question order টা session notes এ JSON হিসেবে রাখব
        String questionOrder = String.join(",", questionIds);
        jdbcTemplate.update(
                "UPDATE user_exam_sessions SET notes = ? WHERE id = ?",
                questionOrder, sessionId);
    }

    private List<String> getSessionQuestions(String sessionId) {
        String notes = jdbcTemplate.queryForObject(
                "SELECT notes FROM user_exam_sessions WHERE id = ?",
                String.class, sessionId);
        if (notes == null || notes.isEmpty()) return new ArrayList<>();
        return Arrays.asList(notes.split(","));
    }

    private QuestionResponse buildQuestionResponse(String questionId,
                                                     int questionNumber,
                                                     int totalQuestions) {
        Map<String, Object> question = fetchQuestion(questionId);
        if (question == null) throw new ResourceNotFoundException(
                "প্রশ্ন পাওয়া যায়নি");

        List<Map<String, Object>> options = jdbcTemplate.queryForList(
                "SELECT id, option_key, option_text, option_text_bn " +
                "FROM options WHERE question_id = ? ORDER BY order_index",
                questionId);

        List<QuestionResponse.OptionResponse> optionResponses = options.stream()
                .map(o -> QuestionResponse.OptionResponse.builder()
                        .optionId((String) o.get("id"))
                        .optionKey((String) o.get("option_key"))
                        .optionText((String) o.get("option_text"))
                        .optionTextBn((String) o.get("option_text_bn"))
                        .build())
                .collect(Collectors.toList());

        return QuestionResponse.builder()
                .questionId(questionId)
                .questionText((String) question.get("question_text"))
                .questionTextBn((String) question.get("question_text_bn"))
                .questionType((String) question.get("question_type"))
                .estimatedTimeSec(((Number) question.get("estimated_time_sec")).intValue())
                .questionNumber(questionNumber)
                .totalQuestions(totalQuestions)
                .options(optionResponses)
                .build();
    }

    private Map<String, Object> fetchQuestion(String questionId) {
        try {
            return jdbcTemplate.queryForMap(
                    "SELECT id, question_text, question_text_bn, " +
                    "question_type, estimated_time_sec " +
                    "FROM questions WHERE id = ?", questionId);
        } catch (Exception e) {
            return null;
        }
    }

    private Map<String, Object> findCorrectOption(String questionId) {
        try {
            return jdbcTemplate.queryForMap(
                    "SELECT id, explanation, explanation_bn " +
                    "FROM options WHERE question_id = ? AND is_correct = 1 LIMIT 1",
                    questionId);
        } catch (Exception e) {
            return null;
        }
    }
    // ─── Session Abandon করা ──────────────────────────────────
@Transactional
public void abandonSession(String userId, String sessionId) {
    ExamSession session = getSession(userId, sessionId);
    if (session.getStatus() == ExamSession.Status.IN_PROGRESS) {
        session.setStatus(ExamSession.Status.ABANDONED);
        session.setCompletedAt(LocalDateTime.now());
        examSessionRepository.save(session);
    }
}
}