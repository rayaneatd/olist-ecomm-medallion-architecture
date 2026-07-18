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
# META     }
# META   }
# META }

# CELL ********************

from pyspark.sql.functions import (
    col
) 

df = spark.sql("SELECT * FROM sales_raw_bronze_dev.catalog.products LIMIT 100")
display(df)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
