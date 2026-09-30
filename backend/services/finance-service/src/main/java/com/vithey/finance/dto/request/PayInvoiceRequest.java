package com.vithey.finance.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;

/**
 * Optional body for {@code POST /api/v1/payments/{paymentId}/pay}.
 *
 * <p>Demo-only overrides. The authoritative amount is always taken from the
 * invoice on the server; the client cannot influence what is charged.
 */
public record PayInvoiceRequest(
    @Schema(example = "SUCCESS", allowableValues = {"SUCCESS", "DECLINED", "PROCESSING", "TIMEOUT"},
        description = "Demo scenario override (dev/demo only).")
    String scenario,
    @Schema(example = "DEMO_CARD", allowableValues = {"DEMO_CARD", "DEMO_BANK", "DEMO_WALLET"},
        description = "Demo payment method override.")
    String paymentMethod
) {
}
