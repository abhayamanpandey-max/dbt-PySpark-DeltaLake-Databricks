# Databricks notebook source
# /// script
# [tool.databricks.environment]
# environment_version = "5"
# ///
# MAGIC %md
# MAGIC ## Question 1 
# MAGIC Remove the Duplicates and only keep latest record!

# COMMAND ----------

from pyspark.sql.functions import  *
from pyspark.sql.window import Window
from pyspark.sql.functions import col

# COMMAND ----------

data=[
(101,'Anurag','2026-04-03'),
(101,'Anurag','2026-05-03'),
(102,'Stuti','2026-05-06'),
(102,'Stuti','2026-06-14'),
(103,'Ravi','2026-07-17')
]

# COMMAND ----------

columns=["customer_id",'Customer_name','Updated_date']

# COMMAND ----------

df=spark.createDataFrame(data,columns)
display(df)

# COMMAND ----------

# MAGIC %md
# MAGIC ### Soltion for Question 1

# COMMAND ----------

window_spec = Window.partitionBy("customer_id") \
                    .orderBy(col("Updated_date").desc())


result_df = df.withColumn(
    "rn",
    row_number().over(window_spec)
).filter(
    col("rn") == 1
).drop("rn")
display(result_df)

# COMMAND ----------

# MAGIC %md
# MAGIC # Question 2: Find Highest Salary Employee Per Department
# MAGIC

# COMMAND ----------

employee_data = [
    (1, "Anurag", "IT", 90000),
    (2, "Shalini", "IT", 85000),
    (3, "Stuti", "HR", 70000),
    (4, "Ritika", "HR", 70000),
    (5, "Vaishnav", "Finance", 95000)
]

employee_columns = [
    "emp_id",
    "emp_name",
    "department",
    "salary"
]

employee_df=spark.createDataFrame(employee_data,employee_columns)


#Window Function Required 
window_spec=Window.partitionBy("department").orderBy(col('salary').desc())

result_df=employee_df.withColumn("salary_rank",row_number().over(window_spec)).filter(col("salary_rank")==1).drop("salary_rank")
display(result_df)

# COMMAND ----------

# DBTITLE 1,Dense Rank Used so that same Salary people in Department are not skipped
result_df=employee_df.withColumn("salary_rank",dense_rank().over(window_spec)).filter(col("salary_rank")==1).drop("salary_rank")
display(result_df)

# COMMAND ----------

# MAGIC %md
# MAGIC # Question 3: Month-over-Month Revenue Growth

# COMMAND ----------

sales_data = [
    (101, "2024-01", 10000),
    (101, "2024-02", 15000),
    (101, "2024-03", 12000),
    (102, "2024-01", 8000),
    (102, "2024-02", 9000),
    (102, "2024-03", 11000)
]

sales_columns = [
    "customer_id",
    "month",
    "revenue"
]


sales_df=spark.createDataFrame(sales_data,sales_columns)

window_spec=Window.partitionBy('customer_id').orderBy('month')

result_df=sales_df.withColumn('previous_month_revenue', lag("revenue").over(window_spec)).withColumn('revenue_difference', col("revenue")-col("previous_month_revenue"))
display(result_df)

# COMMAND ----------

# MAGIC %md
# MAGIC # Question 4: Optimize a Join
# MAGIC

# COMMAND ----------

transaction_data = [
    (1, 101, "IN", 5000),
    (2, 102, "US", 7000),
    (3, 103, "IN", 3000),
    (4, 104, "UK", 9000)
]

country_data = [
    ("IN", "India"),
    ("US", "United States"),
    ("UK", "United Kingdom")
]

transaction_df=spark.createDataFrame(transaction_data,['txn_id','cust_id','country_code','amount'])
country_df=spark.createDataFrame(country_data,['country_code','country_name'])
# display(transaction_df)
# display(country_df)

#Optimized way to join 
display(transaction_df.join(broadcast(country_df),'country_code'))

# COMMAND ----------

# MAGIC %md
# MAGIC # Question 5: Incremental Loading

# COMMAND ----------

orders_data = [
    (1, "Created", "2024-01-01"),
    (2, "Shipped", "2024-01-05"),
    (3, "Delivered", "2024-01-10"),
    (4, "Cancelled", "2024-01-15")
]

last_processed_date='2024-01-10'
orders_df=spark.createDataFrame(orders_data,['order_id','status','updated_at'])

incremental_df=orders_df.filter(col("updated_at")>last_processed_date)
display(incremental_df)
