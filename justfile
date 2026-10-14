# Command contract: replace placeholders with verified, local project commands.
set shell := ["bash", "-uc"]

default:
    @just --list --unsorted

orient:
    @./scripts/orient.sh

verify-state:
    @./scripts/verify-state.sh

checkpoint:
    @./scripts/checkpoint.sh

test:
    @echo "Configure the test recipe for BOS before claiming tests passed" >&2
    @exit 1
