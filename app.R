# install.packages("shiny")
# install.packages("shinydashboard")
# install.packages("plotly")
# install.packages("DBI")
# install.packages("RMariaDB")  # 이미 설치했다면 생략
# install.packages("ggplot2")   # 그래프 시각화를 위해 추천
# install.packages("shinydashboardPlus")
# install.packages("DT")
# install.packages("dotenv")

library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(plotly)
library(DBI)
library(RMariaDB)
library(ggplot2)
library(dotenv)

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

# c_part_list 정의
c_part_list <- c('51700-PI000', '51701-PI000', '51700-PI010', '51701-PI010', 
                 '51700-PI100', '51701-PI100', '52700-PI000', '52701-PI000', 
                 '51700-TD000', '51701-TD000', '51700-TD100', '51701-TD100', 
                 '52700-TD000', '52701-TD000', '49500-TD100', '49500-TD200', 
                 '49600-XA000', '49601-XA000', '49560-DO000')


# UI 구성
ui <- dashboardPage(
  
  dashboardHeader(title = "매출 KPI Dashboard"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("BOM", tabName = "kpi_bom", icon = icon("table")),
      menuItem("KPI Monthly", tabName = "kpi_monthly", icon = icon("table")),
      menuItem("KPI Details", tabName = "kpi_details", icon = icon("table")),
      menuItem("Sales Trends", tabName = "sales_trends", icon = icon("chart-line"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Overview 탭
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
      
      # BOM 탭
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
      
      
      # KPI Monthly 탭
      tabItem(tabName = "kpi_monthly",
              fluidRow(
                box(title = "KPI Monthly Data", status = "primary", solidHeader = TRUE, 
                    h4("월별 KPI 추이를 확인할 수 있습니다. - 업데이트 예정"))
              )
      ),
      
      # KPI Details 탭
      tabItem(tabName = "kpi_details",
              fluidRow(
                box(title = "KPI Data", status = "primary", solidHeader = TRUE, 
                    h4("상세 KPI 데이터를 확인할 수 있습니다. - 업데이트 예정"))
              )
      ),
      # Sales Trends 탭
      tabItem(tabName = "sales_trends",
              fluidRow(
                box(title = "Sales Trends", status = "primary", solidHeader = TRUE, 
                    h4("판매 실적과 계획을 비교하여 추이를 확인할 수 있습니다. - 업데이트 예정")) 
              )
      )
    )
  )
)


# Server 로직
server <- function(input, output, session) {
  
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
  
  
  # Overview 계획 KPI 값 계산
  
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
  
  # Overview 실적 KPI 값 계산
  
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
  
  
  # BOM 테이블 출력
  bom <- kpi_bom %>% 
    group_by(차종, 구분, 완제품품번) %>% 
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
  
 
  # KPI Details 테이블 출력
  # output$kpi_table <- renderTable({
  #   kpi_df
  # })
  
  # Sales Trends 그래프 출력
  # output$sales_plot <- renderPlot({
  #   ggplot(kpi_sales, aes(x = date, y = sales_amount)) +
  #     geom_line(color = "blue") +
  #     labs(title = "Sales Trends", x = "Date", y = "Sales Amount") +
  #     theme_minimal()
  # })
}


# Shiny 앱 실행 시 외부 IP로 설정
shinyApp(ui = ui, server = server)
