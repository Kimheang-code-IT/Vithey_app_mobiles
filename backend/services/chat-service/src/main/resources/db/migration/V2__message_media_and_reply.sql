ALTER TABLE messages
    ADD COLUMN message_type VARCHAR(16) NOT NULL DEFAULT 'TEXT',
    ADD COLUMN file_id UUID,
    ADD COLUMN reply_to_message_id UUID REFERENCES messages (id),
    ADD COLUMN client_message_id VARCHAR(64),
    ADD COLUMN deleted_at TIMESTAMPTZ;

ALTER TABLE messages ALTER COLUMN text DROP NOT NULL;

CREATE UNIQUE INDEX uq_messages_client_id
    ON messages (conversation_id, sender_id, client_message_id)
    WHERE client_message_id IS NOT NULL;
