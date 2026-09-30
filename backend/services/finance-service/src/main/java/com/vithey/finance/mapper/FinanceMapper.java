package com.vithey.finance.mapper;

import com.vithey.finance.dto.response.FeeCategoryResponse;
import com.vithey.finance.dto.response.FeeResponse;
import com.vithey.finance.dto.response.PaymentResponse;
import com.vithey.finance.entity.Fee;
import com.vithey.finance.entity.FeeCategory;
import com.vithey.finance.entity.Payment;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface FinanceMapper {

  @Mapping(target = "paymentId", source = "payment.id")
  @Mapping(target = "feeName", source = "fee.name")
  @Mapping(target = "amount", source = "payment.amount")
  @Mapping(target = "currency", source = "payment.currency")
  @Mapping(target = "status", source = "effectiveStatus")
  @Mapping(target = "dueDate", source = "payment.dueDate")
  @Mapping(target = "paidAt", source = "payment.paidAt")
  PaymentResponse toPaymentResponse(Payment payment, Fee fee, com.vithey.finance.entity.PaymentStatus effectiveStatus);

  @Mapping(target = "feeId", source = "fee.id")
  @Mapping(target = "categoryId", source = "fee.categoryId")
  @Mapping(target = "categoryName", source = "category.name")
  @Mapping(target = "name", source = "fee.name")
  @Mapping(target = "amount", source = "fee.amount")
  @Mapping(target = "currency", source = "fee.currency")
  FeeResponse toFeeResponse(Fee fee, FeeCategory category);

  @Mapping(target = "categoryId", source = "id")
  FeeCategoryResponse toCategoryResponse(FeeCategory category);
}
