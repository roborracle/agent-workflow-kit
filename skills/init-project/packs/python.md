description: Python type hints, naming, docstrings, and async patterns.
globs: ["**/*.py"]
alwaysApply: false

# Python Conventions

## Type Hints (Required)

Always use type hints for function parameters and return values.

```python
from typing import Optional, List, Dict, Tuple

async def process_data(
    payload: bytes,
    session_id: str,
    language: Optional[str] = None
) -> Tuple[bytes, Dict[str, Any]]:
    """Process data through the pipeline."""
    pass
```

- Prefer `Optional[T]` over `Union[T, None]`
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
