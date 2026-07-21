#!/usr/bin/env bash

# Format all V and VSH files in the current directory and subdirectories
find . -type f \( -name "*.v" -o -name "*.vsh" \) -exec v fmt -w {} +