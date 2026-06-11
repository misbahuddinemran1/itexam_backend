package com.examplatform.modules.exam.controller;

import com.examplatform.common.dto.ApiResponse;
import com.examplatform.infrastructure.security.JwtTokenProvider;
import com.examplatform.modules.exam.dto.*;
import com.examplatform.modules.exam.service.PracticeExamService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/user/exam/practice")
@RequiredArgsConstructor
@Tag(name = "Practice Exam", description = "Practice Exam Management")
@SecurityRequirement(name = "Bearer Authentication")
public class PracticeExamController {

    private final PracticeExamService practiceExamService;
    private final JwtTokenProvider jwtTokenProvider;

    // ─── Practice শুরু করা ────────────────────────────────────
    @PostMapping("/start")
    @Operation(summary = "Practice Exam শুরু করা")
    public ResponseEntity<ApiResponse<PracticeSessionResponse>> startPractice(
            HttpServletRequest request,
            @RequestBody PracticeStartRequest body) {
        String userId = extractUserId(request);
        PracticeSessionResponse response =
                practiceExamService.startPractice(userId, body);
        return ResponseEntity.ok(
                ApiResponse.success("Practice শুরু হয়েছে", response));
    }

    // ─── পরবর্তী প্রশ্ন নেওয়া ────────────────────────────────
    @GetMapping("/{sessionId}/next-question")
    @Operation(summary = "পরবর্তী প্রশ্ন নেওয়া")
    public ResponseEntity<ApiResponse<QuestionResponse>> getNextQuestion(
            HttpServletRequest request,
            @PathVariable String sessionId) {
        String userId = extractUserId(request);
        QuestionResponse response =
                practiceExamService.getNextQuestion(userId, sessionId);
        return ResponseEntity.ok(
                ApiResponse.success("প্রশ্ন পাওয়া গেছে", response));
    }

    // ─── Answer Submit করা ────────────────────────────────────
    @PostMapping("/{sessionId}/submit-answer")
    @Operation(summary = "Answer Submit করা")
    public ResponseEntity<ApiResponse<AnswerResultResponse>> submitAnswer(
            HttpServletRequest request,
            @PathVariable String sessionId,
            @RequestBody SubmitAnswerRequest body) {
        String userId = extractUserId(request);
        AnswerResultResponse response =
                practiceExamService.submitAnswer(userId, sessionId, body);
        return ResponseEntity.ok(
                ApiResponse.success("Answer জমা হয়েছে", response));
    }

    // ─── Result দেখা ──────────────────────────────────────────
    @GetMapping("/{sessionId}/result")
    @Operation(summary = "Exam Result দেখা")
    public ResponseEntity<ApiResponse<ExamResultResponse>> getResult(
            HttpServletRequest request,
            @PathVariable String sessionId) {
        String userId = extractUserId(request);
        ExamResultResponse response =
                practiceExamService.getResult(userId, sessionId);
        return ResponseEntity.ok(
                ApiResponse.success("Result পাওয়া গেছে", response));
    }

    // ─── Session Abandon করা ──────────────────────────────────
    @PostMapping("/{sessionId}/abandon")
    @Operation(summary = "Exam ছেড়ে দেওয়া")
    public ResponseEntity<ApiResponse<Void>> abandonSession(
            HttpServletRequest request,
            @PathVariable String sessionId) {
        String userId = extractUserId(request);
        practiceExamService.abandonSession(userId, sessionId);
        return ResponseEntity.ok(
                ApiResponse.success("Exam বাতিল করা হয়েছে", null));
    }

    // ─── Token Extract ────────────────────────────────────────
    private String extractUserId(HttpServletRequest request) {
        String token = request.getHeader("Authorization").substring(7);
        return jwtTokenProvider.getUsernameFromToken(token);
    }
}