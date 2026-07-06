#!/bin/bash
# Script kiểm tra trạng thái toàn bộ cluster

echo "=================================================="
echo "  Hadoop Cluster Status"
echo "=================================================="

echo ""
echo "--- Docker Containers ---"
docker-compose ps

echo ""
echo "--- HDFS Status ---"
docker exec namenode bash -c "hdfs dfsadmin -report" 2>/dev/null || echo "NameNode chưa sẵn sàng"

echo ""
echo "--- YARN Nodes ---"
docker exec resourcemanager bash -c "yarn node -list" 2>/dev/null || echo "ResourceManager chưa sẵn sàng"

echo ""
echo "--- HDFS Files ---"
docker exec namenode bash -c "hadoop fs -ls -R / 2>/dev/null || echo 'HDFS trống'"

echo ""
echo "=================================================="
