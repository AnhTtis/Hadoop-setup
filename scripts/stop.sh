#!/bin/bash
# Script dừng Hadoop cluster

echo "=================================================="
echo "  Dừng Hadoop Cluster"
echo "=================================================="

docker-compose down

echo ""
echo "Cluster đã dừng."
echo "Để xóa luôn volumes (dữ liệu HDFS):"
echo "  docker-compose down -v"
echo ""
