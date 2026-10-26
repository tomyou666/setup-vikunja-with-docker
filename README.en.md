# Vikunja (self-hosted setup)

[日本語](README.md) | **English**

A Docker Compose setup for running the open-source task manager [Vikunja](https://vikunja.io/) locally on Windows.  
It uses the official `vikunja/vikunja` image with PostgreSQL 18, and batch files for one-click start, stop, and version switching.

---

## Quick start

Steps to set up this repository and start Vikunja for the first time.

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) is installed and **running**

### Step 1: Create the environment file (`.env`)

1. Copy `.env.examples` in the repository root to `.env` in the same folder.
   ```powershell
   Copy-Item .env.examples .env
   ```
2. Open `.env` in a text editor and replace the following two values with random strings, then save:
   - `VIKUNJA_SERVICE_SECRET` (secret key used for sessions and similar purposes)
   - `VIKUNJA_DATABASE_PASSWORD` (PostgreSQL password)

### Step 2: Start Vikunja and create an account

1. Double-click (or run) `vikunja-up.bat`.
2. Containers start, and your browser opens `http://localhost:3456` automatically.
   > **Note:** The first start can take tens of seconds while the database initializes. If the page does not load, wait a moment and refresh.
3. There is no default user. Register from **Create account** on the screen.

---

## How-to guides

Everyday operations and environment changes.

### Start and stop

- **Start:** Run `vikunja-up.bat` (runs `docker compose up -d`, then opens the Web UI in a browser).
- **Stop:** Run `vikunja-down.bat` (runs `docker compose down` to stop containers).
  - Stopping does **not** delete task data (`db/`) or attachments (`files/`).

### Switch the version (image tag)

To update or pin a Vikunja version, use `vikunja-tag.bat`.

1. Run `vikunja-tag.bat`.
2. The current tag is shown. Enter the new tag (for example `v2.7.1` or `latest`) and press Enter.
3. The following steps run automatically, in order:
   - Pull the image with `docker pull vikunja/vikunja:<entered-tag>`
   - Update `VIKUNJA_IMAGE_TAG` in `.env`
   - Recreate containers with `docker compose up -d`

\* If the image pull fails, `.env` and running containers are left unchanged.

### Access from another machine or over the LAN

To open Vikunja from a phone or another PC on the LAN, change the public URL.

1. Set `VIKUNJA_SERVICE_PUBLICURL` in `.env` to the URL you will open in the browser (**include port `:3456`**).
   - Example: `VIKUNJA_SERVICE_PUBLICURL=http://192.168.1.10:3456`
2. Run `vikunja-down.bat`, then `vikunja-up.bat` to restart.

> **Important:** If the URL omits the port (`:3456`), signup or login may fail with an `unauthorized` error.

### Pin to the Windows Start menu

Windows often cannot pin `.bat` files directly. Use a shortcut instead.

1. Create a shortcut to `vikunja-up.bat` (or another batch file).
2. Right-click the shortcut and choose **Pin to Start**, or place it here:
   ```text
   %AppData%\Microsoft\Windows\Start Menu\Programs
   ```

### Use with an AI agent (Agent Skills / MCP)

An Agent Skill for managing tasks via the `user-vikunja` MCP server (for example in Cursor) is published at [tomyou666/skills](https://github.com/tomyou666/skills).

Install the Vikunja skill with:

```bash
# Vikunja (user-vikunja MCP)
npx skills@latest add tomyou666/skills/skills/vikunja
```

---

## Configuration reference

### Files and directories

```text
.
├── docker-compose.yml   # Vikunja + PostgreSQL 18 service definitions
├── .env.examples        # Environment file template
├── .env                 # Environment settings (not tracked by Git)
├── files/               # Attachment storage (not tracked by Git)
├── db/                  # PostgreSQL data directory (not tracked by Git)
├── vikunja-up.bat       # Start batch (bring containers up + open browser)
├── vikunja-down.bat     # Stop batch (stop containers)
└── vikunja-tag.bat      # Image tag switch batch
```

### Environment variables (`.env`)

| Variable | Description | Example |
|---|---|---|
| `VIKUNJA_SERVICE_PUBLICURL` | URL reachable from the browser (include the port) | `http://localhost:3456` |
| `VIKUNJA_IMAGE_TAG` | Docker image tag for `vikunja/vikunja` | `latest` / `v2.7.1` |
| `VIKUNJA_SERVICE_SECRET` | Secret key for session signing and related use (long random string) | Output of `openssl rand -base64 48` |
| `VIKUNJA_DATABASE_PASSWORD` | PostgreSQL password (shared by Vikunja and the `db` service) | Output of `openssl rand -base64 32` |

### Service details and endpoints

- **URLs**
  - Web UI: `http://localhost:3456`
  - API info: `http://localhost:3456/api/v1/info`
- **Containers (`docker-compose.yml`)**
  - **Vikunja (`vikunja`)**: image `vikunja/vikunja:${VIKUNJA_IMAGE_TAG:-latest}`, ports `3456:3456`, attachments at `./files:/app/vikunja/files`
  - **PostgreSQL (`db`)**: image `postgres:18`, data at `./db:/var/lib/postgresql`; Vikunja starts after the health check passes
- **File conventions and security**
  - Batch files (`.bat`) are saved as **UTF-8 with BOM** so editors such as Cursor can edit them without mojibake.
  - Contents of `.env`, `db/`, and `files/` are listed in `.gitignore`. Do not commit files that contain passwords or secrets.

---

## See also

- [Vikunja documentation](https://vikunja.io/docs/)
- [Vikunja Docker walkthrough](https://vikunja.io/docs/docker-walkthrough/)
- [GitHub: go-vikunja/vikunja](https://github.com/go-vikunja/vikunja)
- [GitHub: tomyou666/skills (Vikunja Agent Skill)](https://github.com/tomyou666/skills)
