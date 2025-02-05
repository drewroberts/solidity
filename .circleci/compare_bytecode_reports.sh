#!/usr/bin/env bash
set -euo pipefail

#------------------------------------------------------------------------------
# Compares bytecode reports generated by prepare_report.py/.js.
#
# ------------------------------------------------------------------------------
# This file is part of solidity.
#
# solidity is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# solidity is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with solidity.  If not, see <http://www.gnu.org/licenses/>
#
# (c) 2024 solidity contributors.
#------------------------------------------------------------------------------

no_cli_platforms=(
    emscripten
)
native_platforms=(
    ubuntu2004-static
    ubuntu
    osx
    osx_intel
    windows
)
interfaces=(
    cli
    standard-json
)

for preset in "$@"; do
    report_files=()
    for platform in "${no_cli_platforms[@]}"; do
        report_files+=("bytecode-report-${platform}-${preset}.txt")
    done
    for platform in "${native_platforms[@]}"; do
        for interface in "${interfaces[@]}"; do
            report_files+=("bytecode-report-${platform}-${interface}-${preset}.txt")
        done
    done

    echo "Reports to compare:"
    printf -- "- %s\n" "${report_files[@]}"

    if ! diff --brief --report-identical-files --from-file "${report_files[@]}"; then
        diff --unified=0 --report-identical-files --from-file "${report_files[@]}" | head --lines 50
        zip "bytecode-reports-${preset}.zip" "${report_files[@]}"
        exit 1
    fi
done
