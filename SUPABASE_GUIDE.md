# ⚡ Supabase Cheatsheet

## 1. Setup (One-Time)
Run this in PowerShell to install the CLI locally.

**Manual Steps:**
1.  **Download**: Get the latest `supabase_windows_amd64.zip` or Rar file from [GitHub Releases](https://github.com/supabase/cli/releases/latest).
2.  **Extract**: Unzip it and rename the file to `supabase.exe`.
3.  **Place**: Move it into a new folder named `supabase_bin` in this project.
4.  **Alias**: Run this in PowerShell to use it:
    ```powershell
    Set-Alias -Name supabase -Value "$PWD\supabase_bin\supabase.exe"
    ```

---

## 2. Daily Workflow
**Cycle:** `Start` -> `Edit in UI` -> `Save to File`

1.  **Start Supabase**:
    ```powershell
    supabase start
    ```
    *Opens Studio at: `http://localhost:54323`*

2.  **Make Changes**: Go to Studio -> Table Editor -> Edit tables.

3.  **Save Changes**:
    ```powershell
    # Creates specific migration file
    supabase db diff -f my_new_feature_name
    ```

4.  **Reset (Optional)**:
    ```powershell
    # Wipe data & re-apply all migrations (Verify everything works)
    supabase db reset
    ```

---

## 3. Branches (`dev` vs `main`)

| Action | Command |
| :--- | :--- |
| **List Branches** | `supabase branches list` |
| **Create Branch** | `supabase branches create feature/new-login` |
| **Deploy to Dev** | `supabase db push --db-url <dev_connection_string>` |

**To Deploy:**
1. Work locally -> `db diff` (Save locally)
2. Push -> `db push` (Send to Cloud Dev)
3. Merge PR -> Auto-deploys to Main (if CI configured)

---

## 4. Troubleshooting
*   **Stopped working?** -> `supabase stop` -> `supabase start`
*   **Sync Error?** -> `supabase migration repair --status reverted <id>`
