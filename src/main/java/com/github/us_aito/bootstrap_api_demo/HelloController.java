package com.github.us_aito.bootstrap_api_demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
  @GetMapping("/")
  public String index() {
    return "Hello World!";
  }
}
