# Custom Docker Image

## Tại sao cần build custom image?

Image `bde2020/hadoop-*` dừng ở Hadoop 3.2.1 + Java 8 và không còn được maintain. Để dùng Hadoop 3.3.5 + Java 17, project tự build image từ `Dockerfile`.

## Stack

| Component | Phiên bản |
|-----------|-----------|
| Base image | `eclipse-temurin:17-jdk-jammy` |
| Java | 17 (LTS) |
| Hadoop | 3.3.5 |
| `HADOOP_HOME` | `/opt/hadoop` |
| `JAVA_HOME` | `/opt/java/openjdk` |

## Cách hoạt động

Tất cả 5 services (`namenode`, `datanode`, `resourcemanager`, `nodemanager`, `historyserver`) dùng **cùng một image**. Service nào chạy daemon nào do biến môi trường `HADOOP_ROLE` quyết định — xử lý trong `scripts/entrypoint.sh`.

```
Dockerfile → image hadoop-setup
    ├── HADOOP_ROLE=namenode      → hdfs namenode
    ├── HADOOP_ROLE=datanode      → hdfs datanode
    ├── HADOOP_ROLE=resourcemanager → yarn resourcemanager
    ├── HADOOP_ROLE=nodemanager   → yarn nodemanager
    └── HADOOP_ROLE=historyserver → mapred historyserver
```

## Build image

```bash
# Build lần đầu (tự động khi docker-compose up)
docker-compose build

# Build lại sau khi thay đổi Dockerfile hoặc entrypoint.sh
docker-compose build --no-cache

# Build + khởi động
docker-compose up -d --build --scale datanode=3 --scale nodemanager=3
```

## Config files

Các file XML được **mount vào container** (không bake vào image), nên chỉnh config không cần rebuild:

```
config/
├── hadoop-env.sh    → /opt/hadoop/etc/hadoop/hadoop-env.sh  (JAVA_HOME, users)
├── core-site.xml    → /opt/hadoop/etc/hadoop/core-site.xml  (fs.defaultFS)
├── hdfs-site.xml    → /opt/hadoop/etc/hadoop/hdfs-site.xml  (replication, paths)
├── yarn-site.xml    → /opt/hadoop/etc/hadoop/yarn-site.xml  (RM, NM resources)
└── mapred-site.xml  → /opt/hadoop/etc/hadoop/mapred-site.xml (framework, memory)
```

Sau khi sửa XML, chỉ cần restart service liên quan:
```bash
docker-compose restart namenode   # Hoặc datanode, resourcemanager, v.v.
```
