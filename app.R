# install.packages("shiny")
# install.packages("shinydashboard")
# install.packages("plotly")
# install.packages("DBI")
# install.packages("RMariaDB")  # 이미 설치했다면 생략
# install.packages("ggplot2")   # 그래프 시각화를 위해 추천
# install.packages("shinydashboardPlus")
# install.packages("DT")
# install.packages("dotenv")

# 1. 필요 라이브러리 로드 ----
library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(plotly)
library(DBI)
library(RMariaDB)
library(ggplot2)
library(dotenv)
library(stringr)
library(tidyr)

# 2. 데이터베이스 연결 ----
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

# 3. 데이터 로드 및 전처리 ----
# c_part_list 정의
c_part_list <- c('51700-PI000', '51701-PI000', '51700-PI010', '51701-PI010', 
                 '51700-PI100', '51701-PI100', '52700-PI000', '52701-PI000', 
                 '51700-TD000', '51701-TD000', '51700-TD100', '51701-TD100', 
                 '52700-TD000', '52701-TD000', '49500-TD100', '49500-TD200', 
                 '49600-XA000', '49601-XA000', '49560-DO000')


## 3-1. 데이터 프레임 생성 ---- 
KPI_유상포함 <- kpi_df %>% 
  summarise(
    매출_계획_달러 = sum(판매가 * 부품수량 * 판매계획, na.rm = TRUE),
    재료비_계획_달러 = sum(재료비 * 부품수량 * 판매계획, na.rm = TRUE),
    매출_실적_달러 = sum(판매가 * 부품수량 * 판매실적, na.rm = TRUE),
    재료비_실적_달러 = sum(재료비 * 부품수량 * 판매실적, na.rm = TRUE), 
    매출_계획_원화 = sum(판매가 * 부품수량 * 판매계획, na.rm = TRUE) * 1290 / 1000000,
    재료비_계획_원화 = sum(재료비 * 부품수량 * 판매계획, na.rm = TRUE) * 1290 / 1000000,
    매출_실적_원화 = sum(판매가 * 부품수량 * 판매실적, na.rm = TRUE) * 1290 / 1000000,
    재료비_실적_원화 = sum(재료비 * 부품수량 * 판매실적, na.rm = TRUE) * 1290 / 1000000
  )

KPI_유상제외 <- kpi_df %>% 
  filter(소싱업체 != "모비스") %>% 
  summarise(
    매출_계획_달러 = sum(판매가 * 부품수량 * 판매계획, na.rm = TRUE),
    재료비_계획_달러 = sum(재료비 * 부품수량 * 판매계획, na.rm = TRUE),
    매출_실적_달러 = sum(판매가 * 부품수량 * 판매실적, na.rm = TRUE),
    재료비_실적_달러 = sum(재료비 * 부품수량 * 판매실적, na.rm = TRUE), 
    매출_계획_원화 = sum(판매가 * 부품수량 * 판매계획, na.rm = TRUE) * 1290 / 1000000,
    재료비_계획_원화 = sum(재료비 * 부품수량 * 판매계획, na.rm = TRUE) * 1290 / 1000000,
    매출_실적_원화 = sum(판매가 * 부품수량 * 판매실적, na.rm = TRUE) * 1290 / 1000000,
    재료비_실적_원화 = sum(재료비 * 부품수량 * 판매실적, na.rm = TRUE) * 1290 / 1000000
  )

## 3-2. 데이터 시각화 챠트 생성 ----
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

# 재료비 관련 데이터 필터링 및 ggplot 그래프
p2 <- ggplot(kpi_long %>% filter(str_detect(항목, "재료비")), aes(x = 판매월, y = 금액, fill = 항목, text = paste("판매월:", 판매월, "<br>금액:", scales::comma(금액)))) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "월별 재료비 KPI", x = "판매월", y = "금액($)") +
  scale_fill_manual(values = c("재료비_계획" = "lightgreen", "재료비_실적" = "lightcoral")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(labels = scales::comma)


# 4. UI 구성 ----
ui <- dashboardPage(
  
## 4-1. 대시보드 헤더 ----  
  dashboardHeader(title = "매출 KPI Dashboard"),

## 4-2. 사이드 메뉴 ----
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("BOM", tabName = "kpi_bom", icon = icon("table")),
      menuItem("월별 매출, 재료비 KPI", tabName = "sales_kpi", icon = icon("chart-bar")),
      menuItem("KPI Monthly", tabName = "kpi_monthly", icon = icon("table")),
      menuItem("KPI Details", tabName = "kpi_details", icon = icon("table")),
      menuItem("Sales Trends", tabName = "sales_trends", icon = icon("chart-line"))
      
    )
  ),
## 4-3. 대시보드 바디 ----  
  dashboardBody(
    tabItems(
      ### 4-3-1. Overview 탭 ----
      tabItem(tabName = "overview",
              fluidRow(
                box(
                  title = "매출 KPI 계획 - 달러", width = 6, solidHeader = TRUE, status = "primary",
                  "아래 지표는 KPI 계획에 대한 내용임."
                ), 
                box(
                  title = "매출 KPI 실적 - 달러", width = 6, solidHeader = TRUE, status = "primary",
                  "아래 지표는 KPI 실적에 대한 내용임."
                )
              ),
              
              fluidRow(
                # 계획 KPI 값 표시
                column(width = 6, 
                       column(6, valueBoxOutput("pure_sales_plan_usd", width = NULL)),
                       column(6, valueBoxOutput("pure_cost_plan_usd", width = NULL)),
                       column(6, valueBoxOutput("total_sales_plan_usd", width = NULL)),
                       column(6, valueBoxOutput("total_cost_plan_usd", width = NULL)),
                       ),
                # 실적 KPI 값 표시
                column(width = 6, 
                       column(6, valueBoxOutput("pure_sales_actual_usd", width = NULL)),
                       column(6, valueBoxOutput("pure_cost_actual_usd", width = NULL)),
                       column(6, valueBoxOutput("total_sales_actual_usd", width = NULL)),
                       column(6, valueBoxOutput("total_cost_actual_usd", width = NULL)),
                      )
              ), 
              
              fluidRow(
                box(
                  title = "매출 KPI 계획 - 원화", width = 6, solidHeader = TRUE, status = "primary",
                  "아래 지표는 KPI 계획에 대한 내용임. (적용환율 1290원)"
                ), 
                box(
                  title = "매출 KPI 실적 - 원화", width = 6, solidHeader = TRUE, status = "primary",
                  "아래 지표는 KPI 실적에 대한 내용임. (적용환율 1290원)"
                )
              ),
              
              fluidRow(
                # 계획 KPI 값 표시
                column(width = 6, 
                       column(6, valueBoxOutput("pure_sales_plan_krw", width = NULL)),
                       column(6, valueBoxOutput("pure_cost_plan_krw", width = NULL)),
                       column(6, valueBoxOutput("total_sales_plan_krw", width = NULL)),
                       column(6, valueBoxOutput("total_cost_plan_krw", width = NULL))
                ),
                # 실적 KPI 값 표시
                column(width = 6, 
                       column(6, valueBoxOutput("pure_sales_actual_krw", width = NULL)),
                       column(6, valueBoxOutput("pure_cost_actual_krw", width = NULL)),
                       column(6, valueBoxOutput("total_sales_actual_krw", width = NULL)),
                       column(6, valueBoxOutput("total_cost_actual_krw", width = NULL))
                )
              ), 
              
              fluidRow(
                box(
                  title = "데이터 Source", width = 12, solidHeader = TRUE, status = "primary",
                  "파일서버:\\6. KPI\\2025년\\25년 KPI 매출 - v1.06 - BOM Update.xlsx"
                )
              ),
                       

      ),
      
      ### 4-3-2. BOM 탭 ----
      tabItem(tabName = "kpi_bom",
              fluidRow(
                # BOM 제목 섹션
                box(title = "완제품 판매가, 재료비 조회", status = "primary", solidHeader = TRUE, width = 8,
                    DT::DTOutput("bom")
                ), 
                box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
                    selectInput("filter_value", 
                                "완제품 품번 선택:", 
                                choices = c_part_list, 
                                selected = c_part_list[1])
                )
              ),
              fluidRow(
                # 필터 섹션
                box(title = "세부 부품 BOM", status = "primary", solidHeader = TRUE, width = 12,
                    DT::DTOutput("filtered_bom")
                )
              )
      ),
      
      ### 4-3-3. KPI Monthly 탭 ----
      tabItem(tabName = "kpi_monthly",
              fluidRow(
                box(title = "KPI Monthly Data", status = "primary", solidHeader = TRUE, 
                    h4("월별 KPI 추이를 확인할 수 있습니다. - 업데이트 예정일수도 있을까요?"))
              )
      ),
      
      ### 4-3-4. KPI Details 탭 ----
      tabItem(tabName = "kpi_details",
              fluidRow(
                box(title = "KPI Data", status = "primary", solidHeader = TRUE, 
                    h4("상세 KPI 데이터를 확인할 수 있습니다. - 업데이트 예정입니다. "))
              )
      ),
      
      ### 4-3-5. Sales Trends 탭 ----
      tabItem(tabName = "sales_trends",
              fluidRow(
                box(title = "Sales Trends", status = "primary", solidHeader = TRUE, 
                    h4("판매 실적과 계획을 비교하여 추이를 확인할 수 있습니다. - 업데이트 예정")) 
              )
      ), 
      
      ### 4-3-5. 매출과 재료비 탭 ----
      tabItem(tabName = "sales_kpi",
              fluidRow(
                box(title = "월별 매출 KPI", width = 12, plotlyOutput("sales_plot"))
              ), 
              fluidRow(
                box(title = "월별 재료비 KPI", width = 12, plotlyOutput("material_plot"))
              )
              
      )
    )
  )
)



# 5. Server 로직 ----
server <- function(input, output, session) {

  ## 5-1. Overview 계획 KPI 값 계산 ----
  output$pure_sales_plan_usd <- renderValueBox({
    pure_sales_plan_usd <- KPI_유상제외$매출_계획_달러
    valueBox(paste0("$ ", format(pure_sales_plan_usd, big.mark = ",")), "순매출 (유상사급 제외)", icon = icon("dollar-sign"), color = "orange")
  })
  
  output$pure_cost_plan_usd <- renderValueBox({
    pure_cost_plan_usd <- KPI_유상제외$재료비_계획_달러
    valueBox(paste0("$ ", format(pure_cost_plan_usd, big.mark = ",")), "순재료비 (유상사급 제외)", icon = icon("clipboard"), color = "green")
  })
  
  output$total_sales_plan_usd <- renderValueBox({
    total_sales_plan_usd <- KPI_유상포함$매출_계획_달러
    valueBox(paste0("$ ", format(round(total_sales_plan_usd, 1), big.mark = ",")), "총매출 (유상사급 포함)", icon = icon("dollar-sign"), color = "orange")
  })
  output$total_cost_plan_usd <- renderValueBox({
    total_cost_plan_usd <- KPI_유상포함$재료비_계획_달러
    valueBox(paste0("$ ", format(total_cost_plan_usd, big.mark = ",")), "총재료비 (유상사급 포함)", icon = icon("clipboard"), color = "green")
  })

  output$pure_sales_plan_krw <- renderValueBox({
    pure_sales_plan_krw <- KPI_유상제외$매출_계획_원화
    valueBox(paste0(format(round(pure_sales_plan_krw, 1), big.mark = ","), " 백만 원"), "순매출 (유상사급 제외)", icon = icon("dollar-sign"), color = "orange")
  })
  
  output$pure_cost_plan_krw <- renderValueBox({
    pure_cost_plan_krw <- KPI_유상제외$재료비_계획_원화
    valueBox(paste0(format(round(pure_cost_plan_krw, 1), big.mark = ","), " 백만 원"), "순재료비 (유상사급 제외)", icon = icon("clipboard"), color = "green")
  })
  
  output$total_sales_plan_krw <- renderValueBox({
    total_sales_plan_krw <- KPI_유상포함$매출_계획_원화
    valueBox(paste0(format(round(total_sales_plan_krw, 1), big.mark = ","), " 백만 원"), "총매출 (계획, 유상사급 포함)", icon = icon("dollar-sign"), color = "orange")
  })
  
  output$total_cost_plan_krw <- renderValueBox({
    total_cost_plan_krw <- KPI_유상포함$재료비_계획_원화
    valueBox(paste0(format(round(total_cost_plan_krw, 1), big.mark = ","), " 백만 원"), "총재료비 (계획, 유상사급 포함)", icon = icon("clipboard"), color = "green")
  })
  
  ## 5-2. Overview 실적 KPI 값 계산 ----
  output$pure_sales_actual_usd <- renderValueBox({
    pure_sales_actual_usd <- KPI_유상제외$매출_실적_달러
    valueBox(paste0("$ ", format(pure_sales_actual_usd, big.mark = ",")), "순매출 (유상사급 제외)", icon = icon("dollar-sign"), color = "red")
  })
  
  output$pure_cost_actual_usd <- renderValueBox({
    pure_cost_actual_usd <- KPI_유상제외$재료비_실적_달러
    valueBox(paste0("$ ", format(pure_cost_actual_usd, big.mark = ",")), "순재료비 (유상사급 제외)", icon = icon("clipboard"), color = "blue")
  })
  
  output$total_sales_actual_usd <- renderValueBox({
    total_sales_actual_usd <- KPI_유상포함$매출_실적_달러
    valueBox(paste0("$ ", format(round(total_sales_actual_usd, 1), big.mark = ",")), "총매출 (유상사급 포함)", icon = icon("dollar-sign"), color = "red")
  })
  output$total_cost_actual_usd <- renderValueBox({
    total_cost_actual_usd <- KPI_유상포함$재료비_실적_달러
    valueBox(paste0("$ ", format(total_cost_actual_usd, big.mark = ",")), "총재료비 (유상사급 포함)", icon = icon("clipboard"), color = "blue")
  })
  
  output$pure_sales_actual_krw <- renderValueBox({
    pure_sales_actual_krw <- KPI_유상제외$매출_실적_원화
    valueBox(paste0(format(round(pure_sales_actual_krw, 1), big.mark = ","), " 백만 원"), "순매출 (유상사급 제외)", icon = icon("dollar-sign"), color = "red")
  })
  
  output$pure_cost_actual_krw <- renderValueBox({
    pure_cost_actual_krw <- KPI_유상제외$재료비_실적_원화
    valueBox(paste0(format(round(pure_cost_actual_krw, 1), big.mark = ","), " 백만 원"), "순재료비 (유상사급 제외)", icon = icon("clipboard"), color = "blue")
  })
  
  output$total_sales_actual_krw <- renderValueBox({
    total_sales_actual_krw <- KPI_유상포함$매출_실적_원화
    valueBox(paste0(format(round(total_sales_actual_krw, 1), big.mark = ","), " 백만 원"), "총매출 (계획, 유상사급 포함)", icon = icon("dollar-sign"), color = "red")
  })
  
  output$total_cost_actual_krw <- renderValueBox({
    total_cost_actual_krw <- KPI_유상포함$재료비_실적_원화
    valueBox(paste0(format(round(total_cost_actual_krw, 1), big.mark = ","), " 백만 원"), "총재료비 (계획, 유상사급 포함)", icon = icon("clipboard"), color = "blue")
  }) 
  
  
  ## 5-3. BOM 테이블 출력 ----
  bom <- kpi_bom %>% 
    group_by(차종, 구분, `FR.RR`, 완제품품번) %>% 
    summarise(
      판매가 = sum(부품수량 * 판매가),   # 부품수량과 판매가를 곱한 후 그룹별 합계 계산
      재료비 = sum(부품수량 * 재료비)    # 부품수량과 재료비를 곱한 후 그룹별 합계 계산
    ) %>% 
    mutate(완제품품번 = factor(완제품품번, levels = c_part_list)) %>% 
    arrange(완제품품번)
  
  output$bom <- DT::renderDT({
    bom  # BOM 데이터를 가져옵니다. 
  }, options = list(pageLength = 5))
  
  
  # 필터링된 BOM 데이터
  filtered_bom <- reactive({
    req(input$filter_value)  # 필터 값이 선택되어 있는지 확인
    
    kpi_bom %>%
      filter(완제품품번 == input$filter_value)  # 선택된 품번에 맞는 데이터 필터링
  })
  
  output$filtered_bom <- DT::renderDT({
    filtered_bom()  # 필터링된 데이터를 가져옵니다.
  }, options = list(pageLength = 25))
  
  
  ## 5-4. 매출, 재료비 KPI plotly 그래프 출력 ----
  # 매출 KPI plotly 그래프 출력
  output$sales_plot <- renderPlotly({
    ggplotly(p1, tooltip = "text")
  })
  
  # 재료비 KPI plotly 그래프 출력
  output$material_plot <- renderPlotly({
    ggplotly(p2, tooltip = "text")
  })
  
}


# 6. Shiny 앱 실행 ----
shinyApp(ui = ui, server = server)
