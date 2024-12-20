# 1. Load libraries ----
library(DBI)
library(RMariaDB)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(dotenv)
library(stringr)

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

## 3.1 월별 데이터 시각화 ----
kpi_plan
kpi_sales
kpi_bom
kpi_df

# 데이터 집계
kpi_summary <- kpi_df %>%
  group_by(판매월) %>%
  summarise(
    매출_계획 = sum(부품수량 * 판매가 * 판매계획), 
    재료비_계획 = sum(부품수량 * 재료비 * 판매계획),
    매출_실적 = sum(부품수량 * 판매가 * 판매실적), 
    재료비_실적 = sum(부품수량 * 재료비 * 판매실적)
  )

# 데이터 변환: long 형식으로 변환하여 ggplot2에서 다루기 쉽게 만듭니다.
kpi_long <- kpi_summary %>%
  pivot_longer(cols = starts_with("매출") | starts_with("재료비"), 
               names_to = "항목", 
               values_to = "금액")


# 매출 관련 데이터 필터링 및 ggplot 그래프
p1 <- ggplot(kpi_long %>% filter(str_detect(항목, "매출")), aes(x = 판매월, y = 금액, fill = 항목, text = paste("판매월:", 판매월, "<br>금액:", scales::comma(금액)))) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "월별 매출 KPI", x = "판매월", y = "금액($)") +
  scale_fill_manual(values = c("매출_계획" = "skyblue", "매출_실적" = "orange")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(labels = scales::comma)

# ggplotly로 변환하여 plotly 그래프 만들기
plotly_p1 <- ggplotly(p1, tooltip = "text")

# 그래프 출력
plotly_p1


# 재료비 관련 데이터 필터링 및 ggplot 그래프
p2 <- ggplot(kpi_long %>% filter(str_detect(항목, "재료비")), aes(x = 판매월, y = 금액, fill = 항목, text = paste("판매월:", 판매월, "<br>금액:", scales::comma(금액)))) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "월별 재료비 KPI", x = "판매월", y = "금액($)") +
  scale_fill_manual(values = c("재료비_계획" = "lightgreen", "재료비_실적" = "lightcoral")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(labels = scales::comma)

# ggplotly로 변환하여 plotly 그래프 만들기
plotly_p2 <- ggplotly(p2, tooltip = "text")

# 그래프 출력
plotly_p2


