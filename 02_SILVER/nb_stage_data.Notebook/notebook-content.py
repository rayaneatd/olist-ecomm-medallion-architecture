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

# Welcome to your new notebook
# Type here in the cell editor to add code!

df = spark.read.format('DELTA').load('abfss://OList@onelake.dfs.fabric.microsoft.com/sales_raw_bronze_dev.Lakehouse/Tables/catalog/product_categories')

display(df)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

spark.range(2).show()

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
