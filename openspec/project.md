# Project Context

## Purpose
`codeline` preserves and modernizes a vintage 1994 "BoW Code-Line for internet" program so it builds and runs on modern UNIX-like systems.
The project goal is to keep the original lightweight telnet-style experience (post/list code lines, simple admin controls) while making targeted safety and compatibility improvements.

## Tech Stack
- C (single-source program: `codeline.c`)
- POSIX APIs: sockets, `fork`, signals, file I/O, `dup2`, `kill`, `execl`
- Build tooling: `make` + `gcc`
- Runtime files: `codeline.codes` (posted lines), `codeline.motd` (login message)

## Project Conventions

### Code Style
- Keep the codebase simple and C89/C90-friendly, with minimal dependencies.
- Use uppercase macros for configuration/constants (`PORT`, `PROMPT`, `MOTD`, `CODES`).
- Prefer bounded string functions (`vsnprintf`, careful fixed-size buffers) over unsafe variants.
- Check return codes for network and system calls where practical, especially on security-sensitive paths.
- Follow existing function-oriented layout with explicit handlers (`post_handler`, `list_handler`, etc.).

### Architecture Patterns
- Single daemon-style TCP server process using double-fork startup.
- Listener accepts connections and forks per client session.
- Text command interpreter with table-driven dispatch arrays for main/admin menus.
- Flat-file persistence in the process working directory (no database).
- Compile-time configuration via preprocessor macros (port, prompts, password mode).

### Testing Strategy
- No automated test suite currently; validation is primarily manual.
- Core verification flow:
  - Build with `make`
  - Start `./codeline`
  - Connect with a TCP client (for example `telnet`/`nc`) and exercise `POST`, `LIST`, `ADMIN`, and `QUIT`
- For troubleshooting crashes/runtime issues, use `strace -p <pid>` as documented in `README.md`.
- For changes touching input handling, prioritize regression checks around buffer sizes, newline handling, and file/socket error paths.

### Git Workflow
- Repository history shows a simple trunk workflow with occasional pull-request merges.
- Keep commits small and focused; use concise imperative commit messages.
- Existing commit style often uses short prefixes/icons to indicate intent (docs/fix/security), which is acceptable but optional.
- Prefer security hardening and compatibility fixes that preserve the original behavior.

## Domain Context
This project is a retro BBS-style "code line" service from the 1990s warez/IRC scene, maintained mainly for preservation and hobby use.
Users connect over TCP, view an MOTD, then interact with a minimal command prompt.
Admin operations are protected by a shared code (`CODE` or optional encrypted `CR_CODE`) and can clear state or terminate the server.

## Important Constraints
- UNIX-like environments only (depends on POSIX process/network APIs).
- Single-source, low-complexity implementation is preferred over introducing frameworks.
- Persistence is local plaintext files only; no authentication system beyond shared admin code.
- Network protocol is plaintext and not hardened for hostile public exposure (no TLS, no rate limiting, minimal access controls).
- Configuration is compile-time constants in `codeline.c`; runtime configurability is intentionally limited.

## External Dependencies
- System C toolchain (`gcc`, `make`) and standard/POSIX C libraries.
- Optional `crypt()` support when `CR_CODE` mode is enabled (platform-dependent link/runtime requirements).
- No external SaaS, database, or third-party API dependencies.
