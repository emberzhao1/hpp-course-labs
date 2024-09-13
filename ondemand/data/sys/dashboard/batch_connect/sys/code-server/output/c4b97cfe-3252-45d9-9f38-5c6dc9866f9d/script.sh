#!/usr/bin/bash -l


CODE_SERVER_DATAROOT="$HOME/.local/share/code-server"
mkdir -p "$CODE_SERVER_DATAROOT/extensions"

# Expose the password to the server.
export PASSWORD="$password"

# Print compute node.
echo "$(date): Running on compute node ${compute_node}:$port"

CPP_FILE="/u/ezhao1/.vscode/c_cpp_properties.json"

if [[ -f "$CPP_FILE" ]]; then
    CPP_DIR="${TMPDIR:=/tmp/$USER}/cpp-vscode"
    mkdir -p "$CPP_DIR"
    chmod 700 "$CPP_DIR"

    # if the file is empty, let's initialize it
    [ -s "$CPP_FILE" ] || echo '{"configurations": [{ "name": "Linux", "browse": { "databaseFilename": null }}], "version": 4}' > "$CPP_FILE"

    jq --arg dbfile "$CPP_DIR/cpp-vscode.db" \
      '.configurations[0].browse.databaseFilename = $dbfile' \
      "$CPP_FILE" > "$CPP_FILE".new

    mv "$CPP_FILE".new "$CPP_FILE"
  fi

#
# Start Code Server.
#
echo "$(date): Started code-server"
echo ""

/sw/external/vscode/code-server/bin/code-server \
    --auth="password" \
    --bind-addr="0.0.0.0:${port}" \
    --disable-telemetry \
    --ignore-last-opened \
    --user-data-dir="$CODE_SERVER_DATAROOT" \
    --log debug \
    "/u/ezhao1"
