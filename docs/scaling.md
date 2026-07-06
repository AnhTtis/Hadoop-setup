# Hướng dẫn Scale Worker Nodes

## Scale lên/xuống với docker-compose

```bash
# Scale 3 workers (mặc định)
docker-compose up -d --scale datanode=3 --scale nodemanager=3

# Scale lên 5 workers
docker-compose up -d --scale datanode=5 --scale nodemanager=5

# Scale xuống 1 worker (dev/test)
docker-compose up -d --scale datanode=1 --scale nodemanager=1
```

> **Lưu ý:** `datanode` và `nodemanager` không có `container_name` cố định nên Docker tự đánh tên `hadoop-setup-datanode-1`, `hadoop-setup-datanode-2`, v.v.

## Kiểm tra sau khi scale

```bash
# Xem containers đang chạy
docker-compose ps

# Kiểm tra DataNodes đã đăng ký với NameNode
docker exec namenode bash -c "hdfs dfsadmin -report | grep 'Live datanodes'"

# Kiểm tra NodeManagers đã đăng ký với ResourceManager
docker exec resourcemanager bash -c "yarn node -list"
```

## Khi nào nên tăng replication?

| Số DataNode | `dfs.replication` nên đặt |
|-------------|---------------------------|
| 1           | 1                         |
| 2           | 2                         |
| 3+          | 3 (mặc định Hadoop)       |

Chỉnh trong `config/hdfs-site.xml` rồi restart cluster:

```bash
docker-compose restart datanode
```

## Giới hạn khi chạy local

Docker Desktop trên Windows/Mac mặc định giới hạn RAM. Với 3 workers × 4GB = 12GB tối thiểu. Nếu máy ít RAM, giảm trong `config/yarn-site.xml`:

```xml
<property>
  <name>yarn.nodemanager.resource.memory-mb</name>
  <value>2048</value>  <!-- Giảm xuống 2GB mỗi worker -->
</property>
```
