#!/bin/bash

echo "=== Neovim Startup Performance Measurement ==="
echo "Date: $(date)"
echo ""

# Measure startup time with different scenarios
echo "1. Clean startup (no file):"
nvim --startuptime /tmp/startup_clean.log +qall
tail -1 /tmp/startup_clean.log

echo ""
echo "2. Loading a small file:"
echo "print('test')" >/tmp/test.lua
nvim --startuptime /tmp/startup_file.log /tmp/test.lua +qall
tail -1 /tmp/startup_file.log

echo ""
echo "3. Plugin count check:"
nvim --headless -c "lua print('Total plugins: ' .. #require('lazy').plugins())" -c "qall" 2>/dev/null

echo ""
echo "4. Detailed timing (top 10 slowest):"
echo "--- Clean startup ---"
sort -k2 -nr /tmp/startup_clean.log | head -10

echo ""
echo "=== Performance Analysis Complete ==="
echo "Startup logs saved to:"
echo "- /tmp/startup_clean.log"
echo "- /tmp/startup_file.log"

# Cleanup
rm -f /tmp/test.lua
