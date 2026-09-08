# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "ada718c0-6219-4be3-b361-11cc0c313144",
# META       "default_lakehouse_name": "sales_silver",
# META       "default_lakehouse_workspace_id": "cdfb3c3e-d807-4bd6-b688-56180bf6c25d",
# META       "known_lakehouses": [
# META         {
# META           "id": "ada718c0-6219-4be3-b361-11cc0c313144"
# META         },
# META         {
# META           "id": "e772e477-926d-4523-b64a-aadac3e7c8d3"
# META         }
# META       ]
# META     },
# META     "environment": {
# META       "environmentId": "44ec8370-e26d-812d-40ff-3a47e79a13b4",
# META       "workspaceId": "00000000-0000-0000-0000-000000000000"
# META     }
# META   }
# META }

# MARKDOWN ********************

# - # **Catalog Data**
# The catalog contains two tables: products and their categories. The output of this notebook will be a denormalized `product` table. We will conserve the history of each product, and will only use the modern categories also

# PARAMETERS CELL ********************

# CONFIGURATION

ENV        = "DEV"
TABLE_NAME = "products"

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark",
# META   "frozen": false,
# META   "editable": true
# META }

# CELL ********************

# IMPORTS
from pyspark.sql.functions import (
    col, trim
) 

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# MAGIC %%sql
# MAGIC CREATE SCHEMA IF NOT EXISTS catalog;
# MAGIC 
# MAGIC CREATE TABLE IF NOT EXISTS sales_silver.catalog.categories (
# MAGIC     category_id INTEGER,
# MAGIC     category_code STRING,
# MAGIC     category_label STRING,
# MAGIC     parent_category_code STRING
# MAGIC )
# MAGIC USING DELTA;
# MAGIC 
# MAGIC CREATE TABLE IF NOT EXISTS sales_silver.catalog.products (
# MAGIC     -- Columns
# MAGIC     product_id STRING NOT NULL,
# MAGIC     category_id INTEGER,
# MAGIC     product_name_length INTEGER,
# MAGIC     product_description_length INTEGER,
# MAGIC     photo_count INTEGER,
# MAGIC     weight_g INTEGER,
# MAGIC     length_cm INTEGER,
# MAGIC     height_cm INTEGER,
# MAGIC     width_cm INTEGER,
# MAGIC     created_at TIMESTAMP,
# MAGIC 
# MAGIC     -- Technical columns
# MAGIC     scd_start_date TIMESTAMP NOT NULL,
# MAGIC     scd_end_date TIMESTAMP,
# MAGIC     scd_is_current BOOLEAN NOT NULL,
# MAGIC     tech_inserted_at TIMESTAMP NOT NULL
# MAGIC )
# MAGIC USING DELTA
# MAGIC 
# MAGIC TBLPROPERTIES (
# MAGIC     'delta.enableChangeDataFeed' = 'false',
# MAGIC     'microsoft.fabric.vorder.enabled' = 'true'
# MAGIC );


# METADATA ********************

# META {
# META   "language": "sparksql",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# we only keep the modern categories
df_categories = spark.sql("""
    SELECT 
        CAST(category_id AS INT)        AS category_id,
        CAST(category_code AS STRING)    AS category_code,
        CAST(category_label AS STRING)   AS category_label,
        CAST(parent_category_id AS STRING) AS parent_category_code
    FROM sales_raw_bronze_dev.catalog.product_categories
""")
unknown    = [(0,"unknown", "Unknown", None)]
df_unknown = spark.createDataFrame(data=unknown, schema=df_categories.schema)

silver_categories = df_categories.union(df_unknown)

silver_categories.write.format("delta").mode("overwrite").option("mergeSchema", False).saveAsTable(name="catalog.categories")


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************


df_products_csv = spark.read.format("csv") \
                .option("header","true") \
                .load("abfss://DEV_OList@onelake.dfs.fabric.microsoft.com/sales_raw_bronze_dev.Lakehouse/Files/archive/olist_products_dataset.csv")


# df_products_csv = df_products_csv.fillna
display(df_products_csv.limit(10))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
