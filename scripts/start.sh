#!/bin/bash
# Script khởi động Hadoop cluster

set -e

echo "=================================================="
echo "  Khởi động Hadoop Cluster trên Docker"
echo "=================================================="

# Kiểm tra Docker đang chạy
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker chưa chạy. Hãy khởi động Docker trước."
    exit 1
fi

# Tạo thư mục data nếu chưa có
mkdir -p data/input data/output

echo ""
echo "[1/3] Khởi động containers..."
docker-compose up -d

echo ""
echo "[2/3] Chờ NameNode sẵn sàng..."
echo "  (Có thể mất 30-60 giây...)"
for i in $(seq 1 12); do
    if curl -sf http://localhost:9870 > /dev/null 2>&1; then
        echo "  NameNode đã sẵn sàng!"
        break
    fi
    echo "  Thử lần $i/12..."
    sleep 10
done

echo ""
echo "[3/3] Kiểm tra trạng thái containers..."
docker-compose ps

echo ""
echo "=================================================="
echo "  Hadoop Cluster đã khởi động thành công!"
echo "=================================================="
echo ""
echo "  Web UIs:"
echo "  - NameNode UI     : http://localhost:9870"
echo "  - ResourceManager : http://localhost:8088"
echo "  - NodeManager     : http://localhost:8042"
echo "  - History Server  : http://localhost:19888"
echo ""
echo "  Để vào NameNode container:"
echo "  docker exec -it namenode bash"
echo ""
