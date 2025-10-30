#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

REPODIR=$( dirname "$0" )
OUTDIR=$REPODIR/temp

# Clean up and create output directory
rm -rf $OUTDIR
mkdir -p $OUTDIR

echo "--- Running pgscen-load test (CSV output) ---"
pgscen-load 2018-03-02 1 -o $OUTDIR -n 10 --test
test -d "$OUTDIR/load/2018-03-02"

echo "--- Running pgscen-solar test (pickle output) ---"
pgscen-solar 2017-05-27 1 -o $OUTDIR -n 10 --test -p
test -f "$OUTDIR/solar/2017-05-27.p"

echo "--- Running pgscen-wind test (CSV output) ---"
pgscen-wind 2018-05-02 1 -o $OUTDIR -n 10 --test
test -d "$OUTDIR/wind/2018-05-02"

echo "--- Running pgscen-load-solar test (pickle output) ---"
pgscen-load-solar 2017-03-27 1 -o $OUTDIR -n 10 --test -p
test -f "$OUTDIR/load/2017-03-27.p"
test -f "$OUTDIR/solar/2017-03-27.p"

echo "--- Running pgscen command (separate load/solar, CSV) ---"
pgscen 2018-04-10 1 -o $OUTDIR -n 10 --test
test -d "$OUTDIR/load/2018-04-10"
test -d "$OUTDIR/solar/2018-04-10"
test -d "$OUTDIR/wind/2018-04-10"

echo "--- Running pgscen command (joint load/solar, pickle) ---"
pgscen 2018-05-11 1 -o $OUTDIR -n 10 --test --joint -p
test -f "$OUTDIR/load/2018-05-11.p"
test -f "$OUTDIR/solar/2018-05-11.p"
test -f "$OUTDIR/wind/2018-05-11.p"

echo "--- All tests passed! ---"

# Clean up the output directory
rm -r $OUTDIR

echo "Cleanup complete."
