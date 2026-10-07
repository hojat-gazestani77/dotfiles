---
name: python-exception-handling
description: Use when writing, reviewing, or refactoring Python code involving exceptions, error handling, EAFP, resource cleanup, logging, custom exception design, exception chaining, add_note(), or ExceptionGroup.
---

# Python Exception Handling Skill

This skill provides actionable, production-grade principles and a review checklist for AI agents writing, reviewing, or refactoring Python code containing exception and error handling.

---

## Core Principles

### 1. Fail fast
Detect invalid states and unviable conditions as close as possible to their root cause. Do not allow corrupted or invalid input to silently propagate through multiple layers before failing.

**Prefer:**
```python
def calculate_average(numbers: list[float]) -> float:
    if not numbers:
        raise ValueError("cannot calculate average of an empty sequence")
    return sum(numbers) / len(numbers)
```

**Avoid:**
Silently returning `None`, `0`, `-1`, or an error string when an operation genuinely fails, forcing callers to guess whether the result is valid.

---

### 2. Raise low, catch at the lowest sufficient layer
Raise exceptions at the lower layer where the failure is detected. Catch an exception at the lowest layer that has enough information to handle it correctly, while keeping presentation concerns at the appropriate application boundary.

- **Lower layers** (domain models, repositories, utility functions) should raise domain or built-in exceptions. A repository may legitimately catch a database timeout and retry it; it does not need to propagate upward.
- **Higher layers** (CLI commands, HTTP route handlers, GUI event loops, background job runners) own presentation concerns: converting failures into responses, exit codes, or user-facing messages.

Do not propagate an exception upward merely because a higher layer *could* handle it.

**Prefer:**

```python
# Lower layer (service / repository)
def load_user(repository, user_id: int) -> User:
    user = repository.find_by_id(user_id)
    if not user:
        raise UserNotFoundError(f"User {user_id} does not exist")
    return user

# Higher layer (API boundary)
@app.get("/users/{user_id}")
def get_user_endpoint(user_id: int):
    try:
        user = load_user(repository, user_id)
        return user
    except UserNotFoundError as e:
        logger.warning("User lookup failed: %s", e)
        raise HTTPException(status_code=404, detail="User not found")
```

---

### 3. Prefer built-in exceptions
Before defining custom exception classes, check whether an existing Python built-in exception accurately describes the failure condition.

Use standard built-ins for standard conditions:
- `ValueError` — Correct type, but inappropriate value 
- `TypeError` — Inappropriate argument type 
- `KeyError` — Requested dictionary or mapping key does not exist 
- `IndexError` — Sequence index is out of bounds 
- `FileNotFoundError` — Requested file path does not exist 
- `PermissionError` — Operation is not permitted due to OS/file permissions 
- `TimeoutError` — Operation timed out 

Do not create custom exception wrappers that merely duplicate standard built-ins without added domain semantics.

---

### 4. Custom exceptions and exception design rules
Create custom exceptions when the application requires meaningful, domain-level failure concepts that must be distinguished from low-level implementation details.

#### Exception Design Rules:
1. **Inherit from `Exception`**: Base custom domain errors on `Exception` (or a base domain exception), never directly on `BaseException`.
2. **Keep hierarchies shallow**: Define a small, flat exception hierarchy rather than a deep, complex class tree.
3. **Don't expose infrastructure types across architectural boundaries**: Infrastructure exceptions (e.g., `psycopg2.OperationalError`, `redis.ConnectionError`) should not leak into business domain code.
4. **Don't create useless exceptions**: Avoid creating custom exception classes that have no distinct handling behavior or architectural meaning.
5. **Don't encode sensitive information in messages**: Never put passwords, tokens, API keys, or raw personal credentials in exception messages or tracebacks.
6. **Don't catch merely to change the message**: Do not catch an exception solely to re-raise the same exception type with a modified string message.

**Prefer:**
```python
class UserError(Exception):
    """Base class for all user domain errors."""

class UserNotFoundError(UserError):
    """Raised when a requested user does not exist."""

class PasswordInvalidError(UserError):
    """Raised when password validation fails."""
```

---

### 5. Translate implementation exceptions at boundaries
When lower-level code or third-party libraries raise implementation-specific errors, translate them into domain-level exceptions at architectural boundaries. Always preserve the original causal context using `raise ... from e`.

**Prefer:**
```python
class UserRepository:
    def get_user(self, user_id: str) -> User:
        try:
            return self._db_store[user_id]
        except KeyError as e:
            raise UserNotFoundError(f"User {user_id!r} not found") from e
```

---

### 6. Prefer EAFP for risky operations
Embrace the **EAFP** (*Easier to ask forgiveness than permission*) style for operations where attempting the operation itself is the authoritative check and failure is a genuine possibility. Avoid redundant precondition checks (**LBYL** — *Look before you leap*) that introduce race conditions.

**Prefer:**
```python
try:
    with open(config_path, encoding="utf-8") as file:
        return json.load(file)
except FileNotFoundError as e:
    raise ConfigNotFoundError(f"Configuration file missing: {config_path}") from e
```

**Avoid:**
```python
# Vulnerable to Time-of-Check to Time-of-Use (TOCTOU) race condition
if os.path.exists(config_path):
    with open(config_path, encoding="utf-8") as file:
        return json.load(file)
```

---

### 7. Catch the narrowest exception that can be meaningfully handled
At process or application boundaries, `except Exception:` can be appropriate when the boundary intentionally handles otherwise-unhandled failures, for example by logging the traceback, converting the failure into a generic response, performing cleanup, or terminating with a controlled exit.

Do not use a broad catch to continue normal execution after an unknown failure.

**Prefer:**
```python
try:
    port = int(config["port"])
except KeyError as e:
    raise ConfigurationError("Missing mandatory key: 'port'") from e
except ValueError as e:
    raise ConfigurationError("Port must be a valid integer") from e
```

**Avoid:**
```python
try:
    port = int(config["port"])
except Exception:  # Catches unrelated bugs, NameErrors, etc.
    port = 8080
```

---

### 8. Keep try blocks small
Place only the minimal, risky statements whose exceptions you intend to catch inside the `try` clause.

**Prefer:**
```python
try:
    user = user_db[user_id]
except KeyError as e:
    raise UserNotFoundError(f"User {user_id} not found") from e

# Post-processing sits outside the try block
send_welcome_email(user)
```

**Avoid:**
```python
try:
    user = user_db[user_id]
    send_welcome_email(user)  # A KeyError inside send_welcome_email will be misattributed!
except KeyError:
    print("User not found")
```

---

### 9. Resource management: Context managers and `finally`
Clean up external resources (files, network connections, database handles, locks) under all execution outcomes.

Prefer **context managers** (`with` statements) as the primary abstraction for resource management. Use `try...finally` when working with resources that do not support the context manager protocol.

**Prefer (Context Manager):**
```python
with open(file_path, "r", encoding="utf-8") as file:
    data = file.read()
```

**Alternative (`try...finally` when `with` is unavailable):**
```python
resource = acquire_legacy_resource()
try:
    resource.process()
finally:
    resource.release()
```

**Warning:** Do not use `return`, `break`, or `continue` from `finally` blocks — they can suppress exceptions or override control flow:

```python
try:
    operation()
finally:
    return result  # bad: can suppress an exception raised in the try block
```

---

### 10. Use `else` on `try` blocks
Use the optional `else:` clause on `try` statements for code that must execute only if the `try` block succeeds without raising an exception.

The `else` block prevents post-processing operations from accidentally triggering exception handlers designed for the `try` block, reinforcing small `try` blocks.

**Prefer:**
```python
try:
    raw_data = fetch_payload(source)
except FetchError:
    ...
else:
    return process_payload(raw_data)
```

---

### 11. Do not use exceptions for routine control flow
Exceptions represent genuine error conditions or unexpected failures, not ordinary program branching. Use standard `if/else` control flow for expected business decisions.

---

### 12. Do not swallow exceptions
Avoid silent `pass` blocks or converting unrecoverable failures into arbitrary `None` or sentinel values without handling or logging.

If an exception is caught, the code must do one of:
1. Meaningfully recover from the failure.
2. Translate it into a semantic domain exception (`raise NewError(...) from e`).
3. Attach context (`add_note()`) and re-raise.
4. Log it at an application boundary.

If suppression is genuinely intended, make it explicit and narrow:

```python
from contextlib import suppress

with suppress(FileNotFoundError):
    path.unlink()
```

Intentional suppression should be narrow, obvious, and semantically justified. Avoid bare except: pass for suppression; intentional suppression should be narrow, explicit, and semantically justified.

---

### 13. Preserve context: `from e`, `from None`, and bare `raise`

The complete chaining mental model:

| Form | Effect |
|------|--------|
| `raise NewError(...) from e` | Preserves `e` as the explicit cause |
| `raise NewError(...) from None` | Suppresses the displayed implicit context |
| `raise` | Re-raises the active exception, preserving traceback semantics |

- When translating exceptions, use `raise ... from e` to preserve cause and context.
- Use `from None` only when intentionally hiding the lower-level cause from the exception's displayed context, not as the default:
  ```python
  try:
      ...
  except KeyError:
      raise ConfigurationError("invalid configuration") from None
  ```
- When re-raising the current exception, prefer bare `raise` over `raise e` because bare raise preserves the active exception's traceback without adding a new raise location.
- When maintaining the original exception type while attaching contextual metadata, use `BaseException.add_note()`.

**Prefer:**
```python
try:
    parse_config(path)
except ValidationError as e:
    e.add_note(f"Configuration file: {path}")
    raise
```

---

### 14. Logging exceptions
`logger.exception()` logs a message at ERROR level and automatically attaches the current exception's traceback. Use `logger.exception()` while handling an active exception when the traceback is useful. Prefer `logger.error(..., exc_info=True)` when you need explicit control over logging behavior outside the normal exception-handling pattern.

Separate diagnostic logging from user-facing error responses.

**Prefer:**
```python
try:
    process_payment(order)
except PaymentGatewayError:
    logger.exception("Payment processing failed for order %s", order.id)
    return {"error": "Unable to complete payment. Please try again later."}, 500
```

---

### 15. Let unexpected exceptions propagate
If a function cannot recover from, translate, or add context to an exception, let it propagate naturally to higher layers. Do not catch an exception merely to log and immediately re-raise it without value.

---

### 16. Use `ExceptionGroup` and `except*` for concurrent or grouped failures
Use `ExceptionGroup` (and `except*` in Python 3.11+) when multiple independent operations can fail concurrently (e.g., `asyncio.TaskGroup`, parallel service health checks). Do not use `ExceptionGroup` for single routine failures.

---

## Agent Behavior

When writing or modifying Python code:

1. Do not introduce `try/except` unless there is a concrete handling reason.
2. Prefer the narrowest exception type that matches the expected failure.
3. Keep `try` blocks minimal.
4. Preserve the original exception when translating errors.
5. Do not hide unexpected programming errors.
6. Do not add custom exceptions without meaningful semantic value.
7. Do not log and re-raise at multiple layers unless each log adds distinct diagnostic value.
8. Never expose secrets or sensitive data through exception messages or logs.
9. Prefer context managers for resource ownership.
10. When reviewing existing code, distinguish intentional exception handling from accidental exception swallowing.

---

## Code Review Checklist

When reviewing or writing Python exception handling, verify:

- [ ] **Fail Fast**: Is invalid input or unviable state detected early rather than propagating?
- [ ] **Layered Boundaries**: Are low-level infrastructure errors translated into domain errors at architectural boundaries?
- [ ] **Catch Level**: Are exceptions caught at the lowest layer that has enough information to handle them correctly, with presentation concerns kept at the application boundary?
- [ ] **Narrow Catch**: Does `except` target specific exception types rather than broad `except Exception:` (outside process boundaries)?
- [ ] **Small Try Block**: Is the `try` block isolated to only the risky call?
- [ ] **Resource Cleanup**: Are resources managed using `with` context managers or `try...finally`?
- [ ] **Finally Discipline**: Do `finally` blocks avoid `return`, `break`, and `continue`?
- [ ] **Try / Else**: Is `else:` used for happy-path post-processing to avoid accidental exception swallowing?
- [ ] **Chaining**: Is `raise ... from e` used during exception translation, with `from None` only when intentionally hiding the cause?
- [ ] **Bare Raise**: Is bare `raise` used instead of `raise e` when re-raising the current exception?
- [ ] **No Swallowing**: Are exceptions prevented from being silently suppressed with `pass`?
- [ ] **Explicit Suppression**: Is intentional suppression narrow and obvious (`contextlib.suppress`), never bare `except: pass`?
- [ ] **No Control Flow**: Are normal loop or logic conditions driven by standard `if/else` rather than exceptions?
- [ ] **Logging Precision**: Is `logger.exception()` used while handling an active exception, keeping diagnostic traces out of user-facing messages?
- [ ] **Security**: Are sensitive details (credentials, tokens, secrets) kept out of exception messages and logs?
