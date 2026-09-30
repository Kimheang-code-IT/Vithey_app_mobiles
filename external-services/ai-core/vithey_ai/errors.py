class VitheyAIError(Exception):
    """Base exception for all Vithey AI errors."""


class AIClientError(VitheyAIError):
    """Raised when DeepSeek API call fails (after retries)."""


class AIResponseValidationError(VitheyAIError):
    """Raised when AI returns invalid JSON or the payload fails schema validation."""


class EmptyInputError(VitheyAIError):
    """Raised when no activities/posts are provided for CV generation."""


class RateLimitError(VitheyAIError):
    """Raised when too many LLM calls are made within the rate-limit window."""


class InputLimitError(VitheyAIError):
    """Raised when input exceeds configured safety limits (posts count, size...)."""


class UnsupportedLanguageError(VitheyAIError):
    """Raised when a requested CV language is not supported."""
