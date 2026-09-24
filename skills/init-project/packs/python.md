---
description: Python type hints, naming, docstrings, and async patterns.
paths:
  - "**/*.py"
---

# Python Conventions

## Type Hints (Required)

Always use type hints for function parameters and return values. Use built-in generics and `X | None` (Python 3.10+).

```python
from typing import Any

async def process_data(
    payload: bytes,
    session_id: str,
    language: str | None = None
) -> tuple[bytes, dict[str, Any]]:
    """Process data through the pipeline."""
    pass
```

- Prefer `T | None` over `Optional[T]` and `Union[T, None]`; keep `Optional[T]` only in projects pinned below Python 3.10
- Use Pydantic models for data structures
- Pydantic models use PascalCase with `Schema` suffix (e.g., `UserSchema`)

## Naming Conventions

| Entity | Convention | Example |
|--------|-----------|---------|
| Class | PascalCase | `DataPipeline` |
| Function/Method | snake_case | `process_data` |
| Variable | snake_case | `user_count` |
| Constant | UPPER_SNAKE_CASE | `MAX_RETRIES` |
| Private method | Leading underscore | `_validate_input` |
| Pydantic Model | PascalCase + Schema | `UserSchema` |

## Docstrings (Google-style)

```python
def calculate_similarity(text1: str, text2: str) -> float:
    """Calculate semantic similarity between two texts.

    Args:
        text1: First text to compare
        text2: Second text to compare

    Returns:
        Similarity score between 0 and 1

    Raises:
        ValueError: If either text is empty
    """
    pass
```

## Async/Await Patterns

- Use `async def` for I/O-bound operations
- Use `asyncio.gather()` for concurrent tasks
- Prefer `async with` for resource management
- Use `asyncio.Queue` for producer-consumer patterns
