# Read-only Fabric workspace reference (`data/`)

`data/` is a Git submodule of the BOS Fabric workspace repository in Azure DevOps, not a directory of authored source. Its exact URL and tracked branch (`dev`) are recorded in the parent repository's `.gitmodules`. The parent repository is on GitHub. Do not edit, generate into, commit inside, push, or deploy from `data/`.

## Authentication

GitHub uses the GitHub CLI credential helper. The Azure DevOps host `nswdpie-cs-data-analytics.visualstudio.com` uses Windows Git Credential Manager with the DCCEEW account `jack.foster@dpie.nsw.gov.au`, as **host-scoped local Git configuration** in the parent checkout and the initialized submodule. Credentials are held by the credential manager, never in `.gitmodules` or a remote URL. This is the same credential manager and account used for REDP2's Azure DevOps host, but the hosts differ, so the Git helper must be configured separately for BOS. Other clones need their own equivalent host-scoped configuration before initialization; parent-local Git configuration does not necessarily propagate to the clone operation.

## Initialize in a fresh clone

Configure the Azure DevOps host's credential helper and username for Git before the initial submodule clone (for example, in your user Git config or with `GIT_CONFIG_COUNT` / `GIT_CONFIG_KEY_N` / `GIT_CONFIG_VALUE_N` environment entries inherited by child Git processes). Then run `git submodule update --init data`. Do not put passwords or access tokens in commands, URLs, configuration files, or documentation. If the credential manager prompts, authenticate with the DCCEEW account.

After initialization, block accidental pushes in this checkout with `git -C data remote set-url --push origin file:///dev/null`. This push guard is local state, not transported by `.gitmodules`; reapply it in every clone. Verify using `git -C data remote -v`.

## Refresh the pinned reference

From the parent checkout, use `git -C data fetch origin dev` and `git -C data merge --ff-only origin/dev` after checking that `git -C data status --short` is clean. Review the resulting revision and stage **only the parent gitlink** with `git add data`. Do not commit within the submodule. A normal `git submodule update --init data` checks out the pinned commit from the parent and does not advance it to the newest `dev` revision.
