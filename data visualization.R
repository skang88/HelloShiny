# 1. Load libraries ----
library(DBI)
library(RMariaDB)
library(ggplot2)
library(plotly)
library(dotenv)

# 2. Data Load with DB connection ----
# .env 파일 로드
dotenv::load_dot_env()

# 환경변수 읽기
db_address <- Sys.getenv("DB_ADDRESS")
db_name <- Sys.getenv("DB_NAME")
db_user <- Sys.getenv("DB_USER")
db_password <- Sys.getenv("DB_PASSWORD")

# MySQL 데이터베이스 연결
con <- dbConnect(
  RMariaDB::MariaDB(),
  dbname = db_name,
  host = db_address,
  user = db_user,
  password = db_password
)

# 데이터 불러오기
kpi_df <- dbReadTable(con, "KPI_df")
kpi_bom <- dbReadTable(con, "KPI_BOM")
kpi_plan <- dbReadTable(con, "KPI_Plan")
kpi_sales <- dbReadTable(con, "KPI_Sales")

dbDisconnect(con)


# 3. Data visualization ----

