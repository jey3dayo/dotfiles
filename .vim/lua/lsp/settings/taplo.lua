return {
  -- Suppress INFO logs by setting RUST_LOG to warn level
  cmd_env = {
    RUST_LOG = "taplo=warn",  -- Only show warnings and errors from taplo
  },
}