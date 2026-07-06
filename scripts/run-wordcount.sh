#!/bin/bash
# Script chạy ví dụ WordCount MapReduce

set -e

INPUT_FILE=${1:-"data/input/sample.txt"}

echo "=================================================="
echo "  Chạy ví dụ WordCount MapReduce"
echo "=================================================="

# Tạo file input mẫu nếu chưa có
if [ ! -f "$INPUT_FILE" ]; then
    echo "Tạo file input mẫu: $INPUT_FILE"
    cat > "$INPUT_FILE" << 'EOF'
Apache Hadoop is a framework for distributed storage and processing of big data
Hadoop uses HDFS for storage and MapReduce for processing
HDFS stands for Hadoop Distributed File System
MapReduce is a programming model for processing large datasets
YARN is the resource management layer of Hadoop
EOF
fi

echo ""
echo "[1/5] Copy file lên HDFS..."
docker exec namenode bash -c "hadoop fs -mkdir -p /input && hadoop fs -rm -r -f /input/sample.txt" 2>/dev/null || true
docker cp "$INPUT_FILE" namenode:/tmp/sample.txt
docker exec namenode bash -c "hadoop fs -put /tmp/sample.txt /input/"

echo ""
echo "[2/5] Xóa output cũ (nếu có)..."
docker exec namenode bash -c "hadoop fs -rm -r -f /output" 2>/dev/null || true

echo ""
echo "[3/5] Chạy WordCount job..."
docker exec namenode bash -c "
  hadoop jar \$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  wordcount /input /output
"

echo ""
echo "[4/5] Kết quả WordCount:"
echo "--------------------------------------------------"
docker exec namenode bash -c "hadoop fs -cat /output/part-r-00000"

echo ""
echo "[5/5] Copy kết quả về local..."
mkdir -p data/output
docker exec namenode bash -c "hadoop fs -get /output/part-r-00000 /tmp/wordcount-result.txt"
docker cp namenode:/tmp/wordcount-result.txt data/output/wordcount-result.txt

echo ""
echo "=================================================="
echo "  WordCount hoàn thành!"
echo "  Kết quả: data/output/wordcount-result.txt"
echo "=================================================="
