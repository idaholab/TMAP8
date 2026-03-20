#!/bin/bash
# Test the hit format pre-commit hook behavior.
# Creates an isolated git repo, installs the hook logic directly, generates dummy input files
# (well formatted and poorly formatted) and verifies
# it accepts well-formatted .i files and rejects poorly-formatted ones.

REPO_DIR="$(git rev-parse --show-toplevel)"
HIT="$REPO_DIR/moose/framework/contrib/hit/hit"

pass=0
fail=0

run_test() {
    local desc="$1"
    local expected="$2"  # "pass" or "fail"
    local actual_exit="$3"

    if [[ "$expected" == "pass" && "$actual_exit" == "0" ]] || \
       [[ "$expected" == "fail" && "$actual_exit" != "0" ]]; then
        echo "PASS: $desc"
        ((pass++))
    else
        echo "FAIL: $desc (expected commit to $expected, got exit code $actual_exit)"
        ((fail++))
    fi
}

if [[ ! -x "$HIT" ]]; then
    echo "SKIP: hit binary not found at $HIT (build MOOSE first)"
    exit 0
fi

# Set up isolated temp git repo
tmpdir=$(mktemp -d)
trap "rm -rf '$tmpdir'" EXIT

cd "$tmpdir"
git init -q
git config user.email "test@test.com"
git config user.name "Test"

# Point moose/framework/contrib/hit/hit at the real binary via symlink
mkdir -p moose/framework/contrib/hit
ln -s "$HIT" moose/framework/contrib/hit/hit

# Install the hit-format portion of the pre-commit hook directly
mkdir -p .git/hooks
cat > .git/hooks/pre-commit << 'HOOKEOF'
#!/bin/bash
REPO_DIR="$(git rev-parse --show-toplevel)"
HIT="$REPO_DIR/moose/framework/contrib/hit/hit"

if [[ ! -x "$HIT" ]]; then
    echo "Warning: hit binary not found at $HIT, skipping .i file format check" >&2
else
    staged_i_files=$(git diff --staged --name-only -- '*.i')
    if [[ -n "$staged_i_files" ]]; then
        needs_format=false
        while IFS= read -r f; do
            [[ -f "$f" ]] || continue
            tmpfile=$(mktemp)
            git show ":$f" > "$tmpfile"
            "$HIT" format "$tmpfile" 2>/dev/null
            staged_content=$(git show ":$f")
            formatted_content=$(cat "$tmpfile")
            rm -f "$tmpfile"
            if [[ "$staged_content" != "$formatted_content" ]]; then
                echo "File '$f' needs hit formatting. Run: $HIT format $f" >&2
                needs_format=true
            fi
        done <<< "$staged_i_files"
        if $needs_format; then
            echo "" >&2
            echo "Run the above command(s) and re-stage the affected files." >&2
            exit 1
        fi
    fi
fi
HOOKEOF
chmod +x .git/hooks/pre-commit

# Initial empty commit so git diff --staged has a base to compare against
git commit -q --allow-empty -m "init"

# --- Test 1: No .i files staged — hook should pass ---
touch dummy.txt
git add dummy.txt
git commit -q -m "no i files" 2>/dev/null
run_test "No .i files staged — hook passes" "pass" $?

# --- Test 2: Properly formatted .i file — hook should pass ---
cat > good.i << 'EOF'
[Mesh]
  type = GeneratedMesh
  dim = 1
[]
EOF
"$HIT" format good.i  # canonicalize before staging
git add good.i
git commit -q -m "formatted i file" 2>/dev/null
run_test "Properly formatted .i file — hook passes" "pass" $?

# --- Test 3: Poorly formatted .i file — hook should reject ---
# Missing spaces around '=' and missing indentation are formatting violations
printf '[Mesh]\ntype=GeneratedMesh\ndim=1\n[]\n' > bad.i
git add bad.i
git commit -q -m "unformatted i file" 2>/dev/null
run_test "Poorly formatted .i file — hook rejects" "fail" $?

# --- Test 4: Fixed file after rejection — hook should pass ---
"$HIT" format bad.i
git add bad.i
git commit -q -m "fixed i file" 2>/dev/null
run_test "Re-formatted .i file after rejection — hook passes" "pass" $?

echo ""
echo "Results: $pass passed, $fail failed"
[[ $fail -eq 0 ]]
