package com.github.us_aito.bootstrap_api_demo;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component 
public class AccessLogFilter implements Filter {

    private static final Logger logger = LoggerFactory.getLogger(AccessLogFilter.class);

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        // HTTPリクエストの情報を取得
        HttpServletRequest req = (HttpServletRequest) request;

        // アクセス元のIP、メソッド(GET/POST)、URLをログに出す
        logger.info("Access Log: IP={} Method={} URI={}", 
                request.getRemoteAddr(), 
                req.getMethod(), 
                req.getRequestURI());

        chain.doFilter(request, response);
    }
}