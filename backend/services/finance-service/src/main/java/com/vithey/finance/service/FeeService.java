package com.vithey.finance.service;

import com.vithey.finance.dto.response.FeeCategoryResponse;
import com.vithey.finance.dto.response.FeeResponse;
import com.vithey.finance.entity.FeeCategory;
import com.vithey.finance.mapper.FinanceMapper;
import com.vithey.finance.repository.FeeCategoryRepository;
import com.vithey.finance.repository.FeeRepository;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class FeeService {

  private final FeeRepository feeRepository;
  private final FeeCategoryRepository feeCategoryRepository;
  private final FinanceMapper financeMapper;
  private final StudentFinanceAccountService studentFinanceAccountService;

  public FeeService(
      FeeRepository feeRepository,
      FeeCategoryRepository feeCategoryRepository,
      FinanceMapper financeMapper,
      StudentFinanceAccountService studentFinanceAccountService
  ) {
    this.feeRepository = feeRepository;
    this.feeCategoryRepository = feeCategoryRepository;
    this.financeMapper = financeMapper;
    this.studentFinanceAccountService = studentFinanceAccountService;
  }

  @Transactional(readOnly = true)
  public List<FeeResponse> listFees(UUID userId) {
    studentFinanceAccountService.requireAccount(userId);
    Map<UUID, FeeCategory> categories = feeCategoryRepository.findAll().stream()
        .collect(Collectors.toMap(FeeCategory::getId, Function.identity()));

    return feeRepository.findAll().stream()
        .map(fee -> financeMapper.toFeeResponse(fee, categories.get(fee.getCategoryId())))
        .toList();
  }

  @Transactional(readOnly = true)
  public List<FeeCategoryResponse> listCategories(UUID userId) {
    studentFinanceAccountService.requireAccount(userId);
    return feeCategoryRepository.findAll().stream()
        .map(financeMapper::toCategoryResponse)
        .toList();
  }
}
