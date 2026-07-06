# Kiến trúc Cluster

> **Stack:** Hadoop 3.3.5 · Java 17 (eclipse-temurin:17-jdk-jammy) · Docker Compose


## Tổng quan

```
                    ┌─────────────────────────┐
                    │      MASTER NODE         │
                    │                          │
                    │  ┌──────────┐            │
                    │  │NameNode  │ :9870       │
                    │  │ (HDFS)   │            │
                    │  └──────────┘            │
                    │  ┌────────────────┐      │
                    │  │ResourceManager │ :8088 │
                    │  │   (YARN)       │      │
                    │  └────────────────┘      │
                    │  ┌───────────────┐       │
                    │  │HistoryServer  │ :19888 │
                    │  │  (MapReduce)  │       │
                    │  └───────────────┘       │
                    └────────────┬────────────┘
                                 │
              ┌──────────────────┼──────────────────┐
              │                  │                  │
   ┌──────────┴──────┐ ┌────────┴────────┐ ┌───────┴─────────┐
   │   WORKER NODE 1  │ │  WORKER NODE 2  │ │  WORKER NODE 3  │
   │                  │ │                 │ │                 │
   │ ┌────────────┐   │ │ ┌────────────┐  │ │ ┌────────────┐  │
   │ │  DataNode  │   │ │ │  DataNode  │  │ │ │  DataNode  │  │
   │ │  (HDFS)    │   │ │ │  (HDFS)    │  │ │ │  (HDFS)    │  │
   │ └────────────┘   │ │ └────────────┘  │ │ └────────────┘  │
   │ ┌────────────┐   │ │ ┌────────────┐  │ │ ┌────────────┐  │
   │ │NodeManager │   │ │ │NodeManager │  │ │ │NodeManager │  │
   │ │  (YARN)    │   │ │ │  (YARN)    │  │ │ │  (YARN)    │  │
   │ └────────────┘   │ │ └────────────┘  │ │ └────────────┘  │
   └──────────────────┘ └─────────────────┘ └─────────────────┘
```

## Services

| Container | Role | Layer | Port |
|-----------|------|-------|------|
| `namenode` | Master — quản lý metadata HDFS | HDFS | 9870 |
| `resourcemanager` | Master — phân phối tài nguyên | YARN | 8088 |
| `historyserver` | Master — lưu lịch sử job | MapReduce | 19888 |
| `datanode` ×3 | Worker — lưu trữ block data | HDFS | — |
| `nodemanager` ×3 | Worker — chạy containers/tasks | YARN | — |

## Replication Factor

Với 3 DataNodes, `dfs.replication=3` nghĩa là mỗi block dữ liệu được sao chép sang cả 3 node. Đảm bảo tính sẵn sàng cao: mất 2 DataNode vẫn không mất dữ liệu.

## Tài nguyên mỗi Worker

| Thông số | Giá trị |
|----------|---------|
| RAM | 4096 MB |
| CPU | 2 vCores |
| Tổng RAM cluster | 12288 MB (3×4096) |
| Tổng CPU cluster | 6 vCores (3×2) |
