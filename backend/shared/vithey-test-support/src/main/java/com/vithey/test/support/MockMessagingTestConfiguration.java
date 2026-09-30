package com.vithey.test.support;

import static org.mockito.Mockito.mock;

import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;

@TestConfiguration
public class MockMessagingTestConfiguration {

  @Bean
  @Primary
  ConnectionFactory connectionFactory() {
    return mock(ConnectionFactory.class);
  }

  @Bean
  @Primary
  RabbitTemplate rabbitTemplate(ConnectionFactory connectionFactory) {
    return new RabbitTemplate(connectionFactory);
  }
}
