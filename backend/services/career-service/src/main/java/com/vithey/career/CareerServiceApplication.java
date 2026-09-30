package com.vithey.career;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableFeignClients
public class CareerServiceApplication {

  public static void main(String[] args) {
    SpringApplication.run(CareerServiceApplication.class, args);
  }
}
