#!/bin/sh

echo "#define ANGLE_COMMIT_HASH \""`git rev-parse --short=12 HEAD`"\"" > src/common/commit.h
echo "#define ANGLE_COMMIT_HASH_SIZE 12" >> src/common/commit.h
echo "#define ANGLE_COMMIT_DATE \""`git show -s --format="%ci" HEAD`"\"" >> src/common/commit.h
