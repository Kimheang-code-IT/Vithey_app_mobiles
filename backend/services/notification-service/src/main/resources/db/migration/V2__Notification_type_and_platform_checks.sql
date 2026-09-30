ALTER TABLE notifications DROP CONSTRAINT IF EXISTS chk_notifications_type;
ALTER TABLE notifications
    ADD CONSTRAINT chk_notifications_type
    CHECK (type IN (
        'SYSTEM', 'MESSAGE', 'APPLICATION_UPDATE', 'PAYMENT_DUE', 'MENTION',
        'LIKE', 'COMMENT', 'FOLLOW', 'CHAT', 'CHAT_REQUEST', 'PAYMENT', 'JOB'
    ));

ALTER TABLE device_tokens DROP CONSTRAINT IF EXISTS chk_device_tokens_platform;
ALTER TABLE device_tokens
    ADD CONSTRAINT chk_device_tokens_platform
    CHECK (platform IN ('ANDROID', 'IOS'));
