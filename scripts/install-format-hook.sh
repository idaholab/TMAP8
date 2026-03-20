#!/bin/bash

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../"
hookfile="$REPO_DIR/.git/hooks/pre-commit"

if [[ -f $hookfile ]]; then
    echo "'$hookfile' already exists - aborting" 1>&2
    exit 1
fi

cat > $hookfile << 'HOOKEOF'
#!/bin/bash

REPO_DIR="$(git rev-parse --show-toplevel)"
HIT="$REPO_DIR/moose/framework/contrib/hit/hit"

# Check C++ formatting with clang-format
patch=$(git clang-format --diff -- $(git diff --staged --name-only -- src include tests unit))
if [[ "$patch" =~ "no modified files to format" || "$patch" =~ "clang-format did not modify any files" ]]; then
    echo "" > /dev/null
else
    echo ""
    echo "Your code is not properly formatted." >&2
    echo "Run 'git clang-format' to resolve the following issues:" >&2
    echo ""
    echo "$patch"
    exit 1
fi

# Check MOOSE input files with hit format
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

chmod a+x $hookfile

