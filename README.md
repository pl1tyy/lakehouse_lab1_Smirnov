# Практическая №1 — Локальный Lakehouse, ELT и сжатие
**Смирнов Владимир Алексеевич · VK Education · Вариант 1 (TPC-H Q3) · sf5**

## Краткое описание
Реализация запроса TPC-H Q3 «Shipping Priority» на локальном стеке Lakehouse. Данные материализованы из генератора tpch.sf5 в Iceberg/MinIO через Trino. Выполнен анализ производительности сжатия ZSTD и построена медальонная архитектура (Bronze → Silver → Gold).

## Стек технологий
| Сервис | Роль | Почему выбран |
| :--- | :--- | :--- |
| MinIO (SILO) | S3-совместимое объектное хранилище | Open-source альтернатива AWS S3. Позволяет видеть физические объекты и их размеры через веб-консоль. Нативно поддерживает Iceberg. |
| PostgreSQL | БД для метаданных Lakekeeper | Надежная ACID-СУБД для каталога. Обеспечивает стабильность при одновременных обращениях Trino и Spark. |
| Lakekeeper | Iceberg REST Catalog | Управляет версиями таблиц и путями к файлам. Отделяет метаданные от данных, обеспечивая единую точку доступа для разных движков. Проще в развертывании, чем Polaris. |
| Trino (v476) | SQL-движок для ETL | Идеален для CTAS-операций материализации TPC-H благодаря коннектору tpch. Версия 476 выбрана для совместимости с Iceberg Runtime. |
| Metabase | BI-инструмент для Bronze/Gold | Легкий инструмент для визуализации. Подключается к Trino через Presto-драйвер. Позволяет проверять данные без SQL. |

## Воспроизведение стенда
Для поднятия стека использовались следующие команды Docker:

```bash
# MinIO (S3 Storage)
docker run -d --name lakehouse-minio -p 9000:9000 -p 9001:9001 \
  -e MINIO_ROOT_USER=minioadmin -e MINIO_ROOT_PASSWORD=minioadmin \
  pgsty/silo:latest server /data --console-address ":9001"

# PostgreSQL (Metadata DB)
docker run -d --name lakehouse-pg -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:17

# Lakekeeper (Iceberg Catalog)
docker run -d --name lakekeeper --network lakehouse-net \
  -e LAKEKEEPER__PG_ENCRYPTION_KEY=This-is-NOT-Secure! \
  -e LAKEKEEPER__PG_DATABASE_URL_READ=postgresql://postgres:postgres@lakehouse-pg:5432/postgres \
  -e LAKEKEEPER__PG_DATABASE_URL_WRITE=postgresql://postgres:postgres@lakehouse-pg:5432/postgres \
  -p 8181:8181 quay.io/lakekeeper/catalog:latest-main serve

# Trino (SQL Engine)
docker run -d --name trino -p 8080:8080 \
  -v "${PWD}/catalog:/etc/trino/catalog" trinodb/trino:476

# Metabase (BI Tool)
docker run -d --name metabase -p 3000:3000 \
  -e "MB_DB_TYPE=postgres" \
  -e "MB_DB_DBNAME=metabase" \
  -e "MB_DB_PORT=5432" \
  -e "MB_DB_USER=postgres" \
  -e "MB_DB_PASS=postgres" \
  -e "MB_DB_HOST=lakehouse-pg" \
  --network lakehouse-net \
  metabase/metabase:v0.50.8
