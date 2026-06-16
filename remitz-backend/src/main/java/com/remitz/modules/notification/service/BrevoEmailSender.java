package com.remitz.modules.notification.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Brevo (formerly Sendinblue) transactional email sender. Sends HTML email via the
 * Brevo REST API — the same provider used by the Remitz production app.
 *
 * POST https://api.brevo.com/v3/smtp/email
 * Header: api-key: {brevo.api-key}
 * Body: { sender:{name,email}, to:[{email,name}], subject, htmlContent }
 *
 * Exposes the same send(to, subject, html[, toName]) interface as the other senders so it
 * is a drop-in replacement. Configure via brevo.* env vars.
 */
@Service
@Slf4j
public class BrevoEmailSender {

    @Value("${brevo.url:https://api.brevo.com/v3/smtp/email}")
    private String url;

    @Value("${brevo.api-key:}")
    private String apiKey;

    @Value("${brevo.from-email:ramidiu@kreativwebsolutions.com}")
    private String fromEmail;

    @Value("${brevo.from-name:Remitz}")
    private String fromName;

    private final RestTemplate restTemplate = new RestTemplate();

    public boolean send(String toEmail, String subject, String htmlContent) {
        return send(toEmail, subject, htmlContent, toEmail);
    }

    public boolean send(String toEmail, String subject, String htmlContent, String toName) {
        if (apiKey == null || apiKey.isBlank()) {
            log.warn("Brevo API key not configured (brevo.api-key) — skipping email to {}", toEmail);
            return false;
        }
        try {
            Map<String, Object> sender = new HashMap<>();
            sender.put("name", fromName);
            sender.put("email", fromEmail);

            Map<String, Object> to = new HashMap<>();
            to.put("email", toEmail);
            to.put("name", toName != null && !toName.isBlank() ? toName : toEmail);
            List<Object> toList = new ArrayList<>();
            toList.add(to);

            Map<String, Object> body = new HashMap<>();
            body.put("sender", sender);
            body.put("to", toList);
            body.put("subject", subject);
            body.put("htmlContent", htmlContent);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("api-key", apiKey);
            headers.setAccept(List.of(MediaType.APPLICATION_JSON));

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);
            ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.POST, entity, String.class);

            if (response.getStatusCode().is2xxSuccessful()) {
                log.info("Brevo email sent to {}", toEmail);
                return true;
            }
            log.warn("Brevo email to {} failed with status {}", toEmail, response.getStatusCode());
        } catch (Exception e) {
            log.error("Brevo email to {} error: {}", toEmail, e.getMessage());
        }
        return false;
    }
}
