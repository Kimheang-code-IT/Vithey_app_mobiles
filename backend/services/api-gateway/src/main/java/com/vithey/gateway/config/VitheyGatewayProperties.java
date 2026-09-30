package com.vithey.gateway.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "vithey.gateway")
public class VitheyGatewayProperties {

  private RateLimit rateLimit = new RateLimit();

  public RateLimit getRateLimit() {
    return rateLimit;
  }

  public void setRateLimit(RateLimit rateLimit) {
    this.rateLimit = rateLimit;
  }

  public static class RateLimit {

    private int replenishRate = 100;
    private int burstCapacity = 100;
    private int requestedTokens = 1;

    public int getReplenishRate() {
      return replenishRate;
    }

    public void setReplenishRate(int replenishRate) {
      this.replenishRate = replenishRate;
    }

    public int getBurstCapacity() {
      return burstCapacity;
    }

    public void setBurstCapacity(int burstCapacity) {
      this.burstCapacity = burstCapacity;
    }

    public int getRequestedTokens() {
      return requestedTokens;
    }

    public void setRequestedTokens(int requestedTokens) {
      this.requestedTokens = requestedTokens;
    }
  }
}
