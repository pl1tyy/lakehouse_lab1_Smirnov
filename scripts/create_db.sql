CREATE SCHEMA IF NOT EXISTS lakekeeper.lakehouse;

CREATE TABLE lakekeeper.lakehouse.nation   AS SELECT * FROM tpch.sf5.nation;
CREATE TABLE lakekeeper.lakehouse.region   AS SELECT * FROM tpch.sf5.region;
CREATE TABLE lakekeeper.lakehouse.customer AS SELECT * FROM tpch.sf5.customer;
CREATE TABLE lakekeeper.lakehouse.supplier AS SELECT * FROM tpch.sf5.supplier;
CREATE TABLE lakekeeper.lakehouse.part     AS SELECT * FROM tpch.sf5.part;
CREATE TABLE lakekeeper.lakehouse.partsupp AS SELECT * FROM tpch.sf5.partsupp;
CREATE TABLE lakekeeper.lakehouse.orders   AS SELECT * FROM tpch.sf5.orders;

CREATE TABLE lakekeeper.lakehouse.lineitem AS SELECT * FROM tpch.sf5.lineitem;