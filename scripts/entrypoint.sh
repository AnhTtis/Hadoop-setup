#!/bin/bash
set -e

ROLE=${HADOOP_ROLE:-"namenode"}
echo "==> Starting Hadoop daemon: $ROLE"

case "$ROLE" in
  namenode)
    if [ ! -f /hadoop/dfs/name/current/VERSION ]; then
      echo "==> Formatting NameNode..."
      hdfs namenode -format -nonInteractive hadoop-cluster
    fi
    exec hdfs namenode
    ;;
  datanode)
    exec hdfs datanode
    ;;
  resourcemanager)
    exec yarn resourcemanager
    ;;
  nodemanager)
    exec yarn nodemanager
    ;;
  historyserver)
    exec mapred historyserver
    ;;
  *)
    echo "ERROR: Unknown HADOOP_ROLE '$ROLE'"
    echo "Valid values: namenode, datanode, resourcemanager, nodemanager, historyserver"
    exit 1
    ;;
esac
