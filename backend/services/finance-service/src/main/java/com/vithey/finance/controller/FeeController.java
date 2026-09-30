package com.vithey.finance.controller;

import com.vithey.finance.dto.response.FeeCategoryResponse;
import com.vithey.finance.dto.response.FeeResponse;
import com.vithey.finance.security.CurrentUserProvider;
import com.vithey.finance.service.FeeService;
import com.vithey.finance.util.ApiResponseWrapper;
import java.util.List;
import java.util.UUID;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/fees")
@PreAuthorize("hasRole('STUDENT')")
public class FeeController {

  private final FeeService feeService;
  private final CurrentUserProvider currentUserProvider;

  public FeeController(FeeService feeService, CurrentUserProvider currentUserProvider) {
    this.feeService = feeService;
    this.currentUserProvider = currentUserProvider;
  }

  @GetMapping
  ResponseEntity<ApiResponseWrapper<List<FeeResponse>>> listFees() {
    UUID userId = currentUserProvider.requireStudent().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(feeService.listFees(userId)));
  }

  @GetMapping("/categories")
  ResponseEntity<ApiResponseWrapper<List<FeeCategoryResponse>>> listCategories() {
    UUID userId = currentUserProvider.requireStudent().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(feeService.listCategories(userId)));
  }
}
