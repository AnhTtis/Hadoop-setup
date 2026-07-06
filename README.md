# Hadoop Docker Setup

Hướng dẫn triển khai Hadoop cluster (HDFS + YARN + MapReduce) bằng Docker Compose.

## Kiến trúc

```
┌─────────────────────────────────────────────────┐
│                 Hadoop Cluster                   │
│                                                  │
│  ┌──────────┐    ┌──────────┐                   │
│  │NameNode  │    │DataNode  │    HDFS Layer      │
│  │:9870     │◄───│:9864     │                   │
│  └──────────┘    └──────────┘                   │
│                                                  │
│  ┌──────────────┐  ┌───────────┐                │
│  │ResourceManager│  │NodeManager│  YARN Layer    │
│  │:8088         │◄─│:8042      │                │
│  └──────────────┘  └───────────┘                │
│                                                  │
│  ┌─────────────┐                                │
│  │HistoryServer│  MapReduce History              │
│  │:19888       │                                │
│  └─────────────┘                                │
└─────────────────────────────────────────────────┘
```

## Yêu cầu hệ thống

- Docker & Docker Compose đã cài đặt
- RAM: tối thiểu 4GB (khuyến nghị 8GB)
- Disk: tối thiểu 10GB trống
- CPU: 2+ cores

## Cấu trúc thư mục

```
Hadoop-setup/
├── docker-compose.yml          # Cấu hình các service
├── config/
│   ├── core-site.xml           # HDFS filesystem config
│   ├── hdfs-site.xml           # NameNode/DataNode config
│   ├── yarn-site.xml           # YARN ResourceManager config
│   └── mapred-site.xml         # MapReduce config
├── scripts/
│   ├── start.sh                # Khởi động cluster
│   ├── stop.sh                 # Dừng cluster
│   ├── status.sh               # Kiểm tra trạng thái
│   └── run-wordcount.sh        # Chạy ví dụ WordCount
└── data/
    └── input/
        └── sample.txt          # File dữ liệu mẫu
```

## Khởi động nhanh

### 1. Cấp quyền cho scripts

```bash
chmod +x scripts/*.sh
```

### 2. Khởi động cluster

```bash
./scripts/start.sh
# hoặc
docker-compose up -d
```

### 3. Kiểm tra trạng thái

```bash
./scripts/status.sh
```

### 4. Truy cập Web UI

| Service         | URL                     |
|-----------------|-------------------------|
| NameNode        | http://localhost:9870   |
| ResourceManager | http://localhost:8088   |
| NodeManager     | http://localhost:8042   |
| History Server  | http://localhost:19888  |

## Sử dụng HDFS

```bash
# Vào NameNode container
docker exec -it namenode bash

# Tạo thư mục
hadoop fs -mkdir -p /input

# Upload file
hadoop fs -put /path/to/file.txt /input/

# Xem file
hadoop fs -ls /
hadoop fs -cat /input/file.txt

# Xóa
hadoop fs -rm -r /output
```

## Chạy MapReduce WordCount

```bash
# Dùng script tự động
./scripts/run-wordcount.sh data/input/sample.txt

# Hoặc thủ công trong container
docker exec namenode bash -c "
  hadoop jar \$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  wordcount /input /output
"

# Xem kết quả
docker exec namenode bash -c "hadoop fs -cat /output/part-r-00000"
```

## Dừng Cluster

```bash
./scripts/stop.sh           # Giữ dữ liệu
docker-compose down -v      # Xóa cả dữ liệu
```

## Troubleshooting

| Vấn đề | Giải pháp |
|--------|-----------|
| NameNode crash | `docker logs namenode` để xem lỗi |
| Safe mode | `docker exec namenode bash -c "hdfs dfsadmin -safemode leave"` |
| Port bị chiếm | Kiểm tra và dừng service đang dùng port đó |
| Hết RAM | Giảm `yarn.nodemanager.resource.memory-mb` trong `config/yarn-site.xml` |

## Scale DataNode

```bash
docker-compose up -d --scale datanode=3
```
