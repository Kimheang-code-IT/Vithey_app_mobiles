package com.vithey.finance.config;

import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.core.TopicExchange;
import org.springframework.amqp.support.converter.DefaultJackson2JavaTypeMapper;
import org.springframework.amqp.support.converter.Jackson2JavaTypeMapper;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMqConfig {

  public static final String STUDENT_VERIFIED_QUEUE = "finance.student.verified";
  public static final String STUDENT_VERIFIED_ROUTING_KEY = "student.verified";

  @Bean
  TopicExchange vitheyEventsExchange(@Value("${vithey.events.exchange}") String exchangeName) {
    return new TopicExchange(exchangeName, true, false);
  }

  @Bean
  Queue studentVerifiedQueue() {
    return new Queue(STUDENT_VERIFIED_QUEUE, true);
  }

  @Bean
  Binding studentVerifiedBinding(Queue studentVerifiedQueue, TopicExchange vitheyEventsExchange) {
    return BindingBuilder.bind(studentVerifiedQueue)
        .to(vitheyEventsExchange)
        .with(STUDENT_VERIFIED_ROUTING_KEY);
  }

  /**
   * Auth publishes with {@code __TypeId__=com.vithey.auth...StudentVerifiedEvent}.
   * Infer the listener parameter type so cross-service DTO packages do not need to match.
   */
  @Bean
  MessageConverter jsonMessageConverter() {
    Jackson2JsonMessageConverter converter = new Jackson2JsonMessageConverter();
    DefaultJackson2JavaTypeMapper typeMapper = new DefaultJackson2JavaTypeMapper();
    typeMapper.setTypePrecedence(Jackson2JavaTypeMapper.TypePrecedence.INFERRED);
    typeMapper.addTrustedPackages("*");
    converter.setJavaTypeMapper(typeMapper);
    return converter;
  }
}
