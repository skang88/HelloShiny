# 엑셀 파일로 부터 데이터를 수집하여, DB로 전송하는 코드.
# 엑셀 파일이 업데이트 될때마다 실행하여야 하며, 엑셀 데이터의 셀 주소 기반으로 데이터 추출이 이루어지기 때문에, 
# 셀 주소 등이 변경될 때마다 코드도 업데이트 되어야 합니다. 

# 0. Library Loading ---- 
library(readxl)
library(dplyr)
library(tidyr)
library(scales)

# 1. Data Preparation ----

## 1.1 Load BOM Data ----

### 1.1.1 BOM - Axle ---- 

excel_path <- "X:/6. KPI/2025년/25년 KPI 매출 - v1.06 - BOM Update.xlsx"

Axle_NEa_FR <- read_excel(excel_path, sheet = "BOM - Axle", 
                          range = "B5:AT38", col_names = c(paste0("x", 1:45)))

Axle_NEa_RR <- read_excel(excel_path, sheet = "BOM - Axle", 
                          range = "B39:AT63", col_names = c(paste0("x", 1:45)))

Axle_MEa_FR <- read_excel(excel_path, sheet = "BOM - Axle", 
                          range = "B64:AT92", col_names = c(paste0("x", 1:45)))

Axle_MEa_RR <- read_excel(excel_path, sheet = "BOM - Axle", 
                          range = "B93:AT116", col_names = c(paste0("x", 1:45)))

### 1.1.2 BOM - Shaft ----

Shaft_MEa_FR <- read_excel(excel_path, sheet = "BOM - H.Shaft", 
                          range = "B5:AO36", col_names = c(paste0("x", 1:40)))

Shaft_MEa_RR <- read_excel(excel_path, sheet = "BOM - H.Shaft", 
                           range = "B37:AO57", col_names = c(paste0("x", 1:40)))

Shaft_MEa_INNER <- read_excel(excel_path, sheet = "BOM - H.Shaft", 
                           range = "B58:AO58", col_names = c(paste0("x", 1:40)))

### 1.1.3 BOM 데이터 확인 ----
Axle_NEa_FR
Axle_NEa_RR
Axle_MEa_FR
Axle_MEa_RR
Shaft_MEa_FR
Shaft_MEa_RR
Shaft_MEa_INNER

## 1.2 Clean BOM Data ----
Axle_NEa_FR %>% data.frame()
### 1.2.1 Axle BOM ----
# Axle_NEa_FR
tmp1 <- Axle_NEa_FR %>% filter(!is.na(x8)) %>% select(1:7, x8, x38, x43, x44) %>% select(-x5) %>%
  mutate(x0 = '51700-PI000')  # 51700-PI000
tmp2 <- Axle_NEa_FR %>% filter(!is.na(x9)) %>% select(1:7, x9, x38, x43, x44) %>% select(-x5) %>%
  mutate(x0 = '51701-PI000')  # 51701-PI000
tmp3 <- Axle_NEa_FR %>% filter(!is.na(x10)) %>% select(1:7, x10, x38, x43, x44) %>% select(-x5) %>% 
  mutate(x0 = '51700-PI010')  # 51700-PI010
tmp4 <- Axle_NEa_FR %>% filter(!is.na(x11)) %>% select(1:7, x11, x38, x43, x44) %>% select(-x5) %>% 
  mutate(x0 = '51701-PI010')  # 51701-PI010
tmp5 <- Axle_NEa_FR %>% filter(!is.na(x12)) %>% select(1:7, x12, x38, x43, x44) %>% select(-x5) %>% 
  mutate(x0 = '51700-PI100')  # 51700-PI100
tmp6 <- Axle_NEa_FR %>% filter(!is.na(x13)) %>% select(1:7, x13, x38, x43, x44) %>% select(-x5) %>% 
  mutate(x0 = '51701-PI100')  # 51701-PI100

# Axle_NEa_RR
tmp7 <- Axle_NEa_RR %>% filter(!is.na(x8)) %>% select(1:7, x8, x38, x43, x44) %>% select(-x5) %>%
  mutate(x0 = '52700-PI000')  # 52700-PI000
tmp8 <- Axle_NEa_RR %>% filter(!is.na(x9)) %>% select(1:7, x9, x38, x43, x44) %>% select(-x5) %>%
  mutate(x0 = '52701-PI000')  # 52701-PI000


# Axle_MEa_FR
tmp9 <- Axle_MEa_FR %>% filter(!is.na(x8)) %>% select(1:7, x8, x38, x43, x44) %>% select(-x5) %>%
  mutate(x0 = '51700-TD000')  # 51700-TD000
tmp10 <- Axle_MEa_FR %>% filter(!is.na(x9)) %>% select(1:7, x9, x38, x43, x44) %>% select(-x5) %>%
  mutate(x0 = '51701-TD000')  # 51701-TD000
tmp11 <- Axle_MEa_FR %>% filter(!is.na(x10)) %>% select(1:7, x10, x38, x43, x44) %>% select(-x5) %>% 
  mutate(x0 = '51700-TD100')  # 51700-TD100
tmp12 <- Axle_MEa_FR %>% filter(!is.na(x11)) %>% select(1:7, x11, x38, x43, x44) %>% select(-x5) %>% 
  mutate(x0 = '51701-TD100')  # 51701-TD100

# Axle_MEa_RR
tmp13 <- Axle_MEa_RR %>% filter(!is.na(x8)) %>% select(1:7, x8, x38, x43, x44) %>% select(-x5) %>%
  mutate(x0 = '52700-TD000')  # 52700-TD000
tmp14 <- Axle_MEa_RR %>% filter(!is.na(x9)) %>% select(1:7, x9, x38, x43, x44) %>% select(-x5) %>%
  mutate(x0 = '52701-TD000')  # 52701-TD000

# 변수명 일치
colnames(tmp2) <- colnames(tmp1)
colnames(tmp3) <- colnames(tmp1)
colnames(tmp4) <- colnames(tmp1)
colnames(tmp5) <- colnames(tmp1)
colnames(tmp6) <- colnames(tmp1)
colnames(tmp7) <- colnames(tmp1)
colnames(tmp8) <- colnames(tmp1)
colnames(tmp9) <- colnames(tmp1)
colnames(tmp10) <- colnames(tmp1)
colnames(tmp11) <- colnames(tmp1)
colnames(tmp12) <- colnames(tmp1)
colnames(tmp13) <- colnames(tmp1)
colnames(tmp14) <- colnames(tmp1)

# 각 완제품 파트별 BOM 데이터 결합
Axle_BOM <- rbind(tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11, tmp12, tmp13, tmp14) %>% 
  filter(x1 != '완제품')

# 전체 데이터 갯수 확인 (엑셀 BOM 셀 갯수와 일치)
Axle_BOM %>% count(x3)
Axle_BOM %>% count(x3, x2)
Axle_BOM %>% count(x3, x2, x0) %>% rename(부품종류 = n)


### 1.2.2 Shaft BOM ----
tmp1 <- Shaft_MEa_FR %>% filter(!is.na(x7)) %>% select(1:6, x7, x37, x38, x39) %>% 
  mutate(x0 = '49500-TD100')  # 49500-TD100
tmp2 <- Shaft_MEa_FR %>% filter(!is.na(x8)) %>% select(1:6, x8, x37, x38, x39) %>% 
  mutate(x0 = '49500-TD200')  # 49500-TD200

tmp3 <- Shaft_MEa_RR %>% filter(!is.na(x7)) %>% select(1:6, x7, x37, x38, x39) %>% 
  mutate(x0 = '49600-XA000')  # 49600-XA000
tmp4 <- Shaft_MEa_RR %>% filter(!is.na(x8)) %>% select(1:6, x8, x37, x38, x39) %>% 
  mutate(x0 = '49601-XA000')  # 49601-XA000

Shaft_MEa_INNER <- Shaft_MEa_INNER %>% select(1:7, x37, x38, x39) %>% 
  mutate(x0 = '49560-DO000')  # 49560-DO000

# 변수명 일치
tmp1
colnames(tmp2) <- colnames(tmp1)
colnames(tmp3) <- colnames(tmp1)
colnames(tmp4) <- colnames(tmp1)

# 각 완제품 파트별 데이터 확인
tmp1
tmp2
tmp3
tmp4

Shaft_BOM <- rbind(tmp1, tmp2, tmp3, tmp4) %>% 
  filter(x1 != '완제품')



# 전체 데이터 갯수 확인 (엑셀 BOM 셀 갯수와 일치)
Shaft_BOM %>% count(x3)
Shaft_BOM %>% count(x3, x2)
Shaft_BOM %>% count(x3, x2, x0) %>% rename(부품종류 = n)

# Inner는 BOM이 없음 완제품 그자체임.  
Shaft_MEa_INNER

## 1.3 Merge ALL BOM Data ----
Axle_BOM
colnames(Shaft_BOM) <- colnames(Axle_BOM)
colnames(Shaft_MEa_INNER) <- colnames(Axle_BOM)
BOM <- rbind(Axle_BOM, Shaft_BOM, Shaft_MEa_INNER)

Axle_BOM %>% count(x0)
Shaft_BOM %>% count(x0)
Shaft_MEa_INNER %>% count(x0)
BOM %>% count(x0)
BOM <- BOM %>% mutate(
  x38 = ifelse(is.na(x38), "없음", x38), # 문자형 열
  x43 = ifelse(is.na(x43), 0, x43),          # 수치형 열
  x44 = ifelse(is.na(x44), 0, x44)          # 수치형 열
) %>% rename(
  제품구분 = x1, 차종 = x2, 구분 = x3, `FR/RR` = x4, 품번 = x6, 품명 = x7, 부품수량 = x8, 소싱업체 = x38, 판매가 = x43, 재료비 = x44, 완제품품번 = x0
)


## 1.4 Load Plan Data ----

# 25년 생산 계획 import
BOM %>% count(차종, 구분, 완제품품번) %>% count(구분, 차종)
Axle_NEa_list <- c("51700-PI000", "51701-PI000", "51700-PI010", "51701-PI010", "51700-PI100", "51701-PI100", "52700-PI000", "52701-PI000")
Axle_MEa_list <- c('51700-TD000', '51701-TD000', '51700-TD100', '51701-TD100', '52700-TD000', '52701-TD000')
Shaft_MEa_list <- c('49500-TD100', '49500-TD200', '49600-XA000', '49601-XA000', '49560-DO000')

Axle_NEa_Plan <- read_excel(excel_path, sheet = "3-2. AXLE 사업계획 물량", 
           range = "F8:S15", col_names = c(paste0("x", 1:14)))
Axle_MEa_Plan <- read_excel(excel_path, sheet = "3-2. AXLE 사업계획 물량", 
                            range = "F17:S22", col_names = c(paste0("x", 1:14)))
Shaft_MEa_Plan <- read_excel(excel_path, sheet = "3-2. H.Shaft 사업계획 물량", 
                             range = "F8:S12", col_names = c(paste0("x", 1:14)))

Plan_MM <- rbind(Axle_NEa_Plan, Axle_MEa_Plan, Shaft_MEa_Plan) %>% 
  rename(
    `202501` = x3, 
    `202502` = x4, 
    `202503` = x5, 
    `202504` = x6, 
    `202505` = x7, 
    `202506` = x8, 
    `202507` = x9, 
    `202508` = x10, 
    `202509` = x11, 
    `202510` = x12, 
    `202511` = x13, 
    `202512` = x14
  )
  

Plan <- Plan_MM %>% pivot_longer(
  cols = `202501`:`202512`, 
  names_to = 'month', 
  values_to = 'plan_quantity'
) %>% 
  rename(완제품품번 = x1, 옵션율 = x2, 판매월 = month, 판매계획 = plan_quantity) %>% select(-옵션율) %>% 
  mutate(판매계획 = replace_na(판매계획, 0))  # 결측치를 0으로 대체


## 1.5 Load 실적 Data----
Sales_MM <- read_excel(excel_path, sheet = "25년 매출 및 재료비 (실적)", 
                            range = "F6:T27", col_names = c("완제품품번", "판매가", "재료비", 202501:202512)) %>% filter(!is.na(완제품품번))

# 판매가 재료비 비교 검증
tmp1 <- BOM %>% 
  filter(소싱업체 != "모비스") %>% 
  mutate(판매가 = 부품수량 * 판매가, 재료비 = 부품수량 * 재료비) %>% 
  group_by(구분, 차종, `FR/RR`, 완제품품번) %>% 
  summarise(    
    판매가 = sum(판매가, na.rm = TRUE),
    재료비 = sum(재료비, na.rm = TRUE)
  )

tmp2 <- Sales_MM %>% select(완제품품번, 판매가, 재료비)

# BOM과 판매가의 단가 비교
left_join(tmp1, tmp2, by = "완제품품번")  # 일치함

Sales <- Sales_MM %>% select(-판매가, -재료비) %>% pivot_longer(
  cols = `202501`:`202512`, 
  names_to = '판매월', 
  values_to = '판매실적'
)
Sales %>% count(완제품품번)
Plan %>% count(완제품품번)

left_join(Sales %>% count(완제품품번),
          Plan %>% count(완제품품번), by = "완제품품번")

## 1.6 Merge Plan, 실적, BOM ---- 

### 1.6.1 Rename Variables ----
# Already changed variable's names in the above sections. 


### 1.6.2 Join with BOM and Plan ----
tmp1 <- left_join(Plan, Sales, by = c("완제품품번", "판매월"))
BOM %>% count(완제품품번)
BOM %>% filter(완제품품번 == "51700-PI100") %>% print(n=30)
df <- left_join(BOM, tmp1, by = "완제품품번", relationship = "many-to-many")
df
Sales
Plan

# 품번 정렬을 위한 리스트
values <- c("51700-PI000", "51701-PI000", "51700-PI010", "51701-PI010", 
            "51700-PI100", "51701-PI100", "52700-PI000", "52701-PI000", 
            "51700-TD000", "51701-TD000", "51700-TD100", "51701-TD100", 
            "52700-TD000", "52701-TD000", "49500-TD100", "49500-TD200", 
            "49600-XA000", "49601-XA000", "49560-DO000")

### 1.6.3 Validate with entire value ----

# 유상사급 포함 (총매출) 재료비, 판매가 X 계획, 실적 
df %>% 
  summarise(
    판매가_계획_달러 = sum(판매가 * 부품수량 * 판매계획, na.rm = TRUE),
    재료비_계획_달러 = sum(재료비 * 부품수량 * 판매계획, na.rm = TRUE),
    판매가_실적_달러 = sum(판매가 * 부품수량 * 판매실적, na.rm = TRUE),
    재료비_실적_달러 = sum(재료비 * 부품수량 * 판매실적, na.rm = TRUE), 
    판매가_계획_원화 = sum(판매가 * 부품수량 * 판매계획, na.rm = TRUE) * 1290 / 1000000,
    재료비_계획_원화 = sum(재료비 * 부품수량 * 판매계획, na.rm = TRUE) * 1290 / 1000000,
    판매가_실적_원화 = sum(판매가 * 부품수량 * 판매실적, na.rm = TRUE) * 1290 / 1000000,
    재료비_실적_원화 = sum(재료비 * 부품수량 * 판매실적, na.rm = TRUE) * 1290 / 1000000
  )

# 유상사급 제외 (순매출) 재료비, 판매가 X 계획, 실적 
df %>% 
  filter(소싱업체 != "모비스") %>% 
  summarise(
    판매가_계획 = sum(판매가 * 부품수량 * 판매계획, na.rm = TRUE),
    재료비_계획 = sum(재료비 * 부품수량 * 판매계획, na.rm = TRUE),
    판매가_실적 = sum(판매가 * 부품수량 * 판매실적, na.rm = TRUE),
    재료비_실적 = sum(재료비 * 부품수량 * 판매실적, na.rm = TRUE),
    판매가_계획_원화 = sum(판매가 * 부품수량 * 판매계획, na.rm = TRUE) * 1290 / 1000000,
    재료비_계획_원화 = sum(재료비 * 부품수량 * 판매계획, na.rm = TRUE) * 1290 / 1000000,
    판매가_실적_원화 = sum(판매가 * 부품수량 * 판매실적, na.rm = TRUE) * 1290 / 1000000,
    재료비_실적_원화 = sum(재료비 * 부품수량 * 판매실적, na.rm = TRUE) * 1290 / 1000000
  )

# 유상사급 포함
df %>% 
  mutate(완제품품번 = factor(완제품품번, levels = values)) %>% 
  group_by(구분, 차종, 완제품품번) %>% 
  
  mutate(판매가 = 부품수량 * 판매가 * 판매계획, 재료비 = 부품수량 * 재료비 * 판매계획) %>% 
  summarise(    
    판매가 = sum(판매가, na.rm = TRUE),
    재료비 = sum(재료비, na.rm = TRUE)
  ) %>% 
  mutate(
    판매가 = format(판매가, nsmall = 2),
    재료비 = format(재료비, nsmall = 2)
  ) %>% 
  arrange(완제품품번)

# 액슬  NEa PE 51700-PI100 " 5450454.71" " 5286305.02"
df %>% 
  filter(완제품품번 == '51700-PI100') %>% 
  print(n=360)
df %>% 
  filter(완제품품번 == '51701-PI100')


# 재료비 판매가 49600-XA000, 49601-XA000 품번에 대해 불일치 한경우가 있었는데, 
# 소싱업체가 공란으로 되어 있어  그룹섬에 빠져있었음. 결측치 처리 후 값 일치함. 
# 
df %>% 
  # filter(완제품품번 == '49560-DO000') %>% 
  # filter(소싱업체 != '모비스') %>% 
  mutate(판매가 = 부품수량 * 판매가 * 판매계획, 재료비 = 부품수량 * 재료비 * 판매계획) %>% 
  summarise(    
    판매가 = sum(판매가, na.rm = TRUE),
    재료비 = sum(재료비, na.rm = TRUE)
  )

df %>% 
  # filter(완제품품번 == '49560-DO000') %>% 
  filter(소싱업체 != '모비스') %>% 
  mutate(판매가 = 부품수량 * 판매가 * 판매계획, 재료비 = 부품수량 * 재료비 * 판매계획) %>% 
  summarise(    
    판매가 = sum(판매가, na.rm = TRUE),
    재료비 = sum(재료비, na.rm = TRUE)
  )

# 완제품 단가 소수점 2자리 표시
BOM %>% 
  #filter(구분 == '등속') %>% 
  group_by(차종, 구분, 완제품품번) %>% 
  mutate(판매가 = 부품수량 * 판매가, 재료비 = 부품수량 * 재료비) %>% 
  summarise(    
    판매가 = sum(판매가, na.rm = TRUE),
    재료비 = sum(재료비, na.rm = TRUE)
  ) %>% 
  mutate(
    판매가 = number(판매가, accuracy = 0.01),
    재료비 = number(재료비, accuracy = 0.01)
  )

# 완제품 단가 소수점 그대로 표시
BOM %>% mutate(판매가 = 부품수량 * 판매가, 재료비 = 부품수량 * 재료비) %>% 
  group_by(구분, 차종, `FR/RR`, 완제품품번) %>% 
  summarise(    
    판매가 = sum(판매가, na.rm = TRUE),
    재료비 = sum(재료비, na.rm = TRUE)
  ) %>% 
  mutate(
    판매가 = format(판매가, nsmall = 2),
    재료비 = format(재료비, nsmall = 2)
  )


# 2. Transfer Dataframe and BOM to Database ----
library(RMariaDB)

con <- dbConnect(
  RMariaDB::MariaDB(),
  dbname = "SAG", 
  host = "172.16.220.32",
  port = 3306, 
  user = "seokgyun", 
  password = "1q2w3e4r"
)

# DataFrame을 MySQL에 새로운 테이블로 전송
dbWriteTable(con, "KPI_df", df, overwrite = TRUE, row.names = FALSE)
dbWriteTable(con, "KPI_BOM", BOM, overwrite = TRUE, row.names = FALSE)
dbWriteTable(con, "KPI_Plan", Plan, overwrite = TRUE, row.names = FALSE)
dbWriteTable(con, "KPI_Sales", Sales, overwrite = TRUE, row.names = FALSE)

dbReadTable(con, "KPI_df")
dbReadTable(con, "KPI_BOM")
dbReadTable(con, "KPI_Plan")
dbReadTable(con, "KPI_Sales")

dbDisconnect(con)

## 2.1 KPI Contents ----

### 2.1.1 Overview ----

KPI_유상포함 <- df %>% 
  summarise(
    판매가_계획_달러 = sum(판매가 * 부품수량 * 판매계획, na.rm = TRUE),
    재료비_계획_달러 = sum(재료비 * 부품수량 * 판매계획, na.rm = TRUE),
    판매가_실적_달러 = sum(판매가 * 부품수량 * 판매실적, na.rm = TRUE),
    재료비_실적_달러 = sum(재료비 * 부품수량 * 판매실적, na.rm = TRUE), 
    판매가_계획_원화 = sum(판매가 * 부품수량 * 판매계획, na.rm = TRUE) * 1290 / 1000000,
    재료비_계획_원화 = sum(재료비 * 부품수량 * 판매계획, na.rm = TRUE) * 1290 / 1000000,
    판매가_실적_원화 = sum(판매가 * 부품수량 * 판매실적, na.rm = TRUE) * 1290 / 1000000,
    재료비_실적_원화 = sum(재료비 * 부품수량 * 판매실적, na.rm = TRUE) * 1290 / 1000000
  )

KPI_유상제외 <- df %>% 
  filter(소싱업체 != "모비스") %>% 
  summarise(
    판매가_계획_달러 = sum(판매가 * 부품수량 * 판매계획, na.rm = TRUE),
    재료비_계획_달러 = sum(재료비 * 부품수량 * 판매계획, na.rm = TRUE),
    판매가_실적_달러 = sum(판매가 * 부품수량 * 판매실적, na.rm = TRUE),
    재료비_실적_달러 = sum(재료비 * 부품수량 * 판매실적, na.rm = TRUE), 
    판매가_계획_원화 = sum(판매가 * 부품수량 * 판매계획, na.rm = TRUE) * 1290 / 1000000,
    재료비_계획_원화 = sum(재료비 * 부품수량 * 판매계획, na.rm = TRUE) * 1290 / 1000000,
    판매가_실적_원화 = sum(판매가 * 부품수량 * 판매실적, na.rm = TRUE) * 1290 / 1000000,
    재료비_실적_원화 = sum(재료비 * 부품수량 * 판매실적, na.rm = TRUE) * 1290 / 1000000
  )


### 2.1.1 KPI Monthly Data ----

KPI_monthly_유상포함 <- df %>% 
  group_by(판매월) %>% 
  summarise(
    판매가_계획_달러 = sum(판매가 * 부품수량 * 판매계획, na.rm = TRUE),
    재료비_계획_달러 = sum(재료비 * 부품수량 * 판매계획, na.rm = TRUE),
    판매가_실적_달러 = sum(판매가 * 부품수량 * 판매실적, na.rm = TRUE),
    재료비_실적_달러 = sum(재료비 * 부품수량 * 판매실적, na.rm = TRUE), 
    판매가_계획_원화 = sum(판매가 * 부품수량 * 판매계획, na.rm = TRUE) * 1290 / 1000000,
    재료비_계획_원화 = sum(재료비 * 부품수량 * 판매계획, na.rm = TRUE) * 1290 / 1000000,
    판매가_실적_원화 = sum(판매가 * 부품수량 * 판매실적, na.rm = TRUE) * 1290 / 1000000,
    재료비_실적_원화 = sum(재료비 * 부품수량 * 판매실적, na.rm = TRUE) * 1290 / 1000000
  )

KPI_monthly_유상제외 <- df %>% 
  filter(소싱업체 != "모비스") %>% 
  group_by(판매월) %>% 
  summarise(
    판매가_계획_달러 = sum(판매가 * 부품수량 * 판매계획, na.rm = TRUE),
    재료비_계획_달러 = sum(재료비 * 부품수량 * 판매계획, na.rm = TRUE),
    판매가_실적_달러 = sum(판매가 * 부품수량 * 판매실적, na.rm = TRUE),
    재료비_실적_달러 = sum(재료비 * 부품수량 * 판매실적, na.rm = TRUE), 
    판매가_계획_원화 = sum(판매가 * 부품수량 * 판매계획, na.rm = TRUE) * 1290 / 1000000,
    재료비_계획_원화 = sum(재료비 * 부품수량 * 판매계획, na.rm = TRUE) * 1290 / 1000000,
    판매가_실적_원화 = sum(판매가 * 부품수량 * 판매실적, na.rm = TRUE) * 1290 / 1000000,
    재료비_실적_원화 = sum(재료비 * 부품수량 * 판매실적, na.rm = TRUE) * 1290 / 1000000
  )

df

BOM %>% filter(완제품품번 == c_part_list[2])
  
c_part_list <- c('51700-PI000', '51701-PI000', '51700-PI010', '51701-PI010', '51700-PI100', '51701-PI100', '52700-PI000', '52701-PI000', 
  '51700-TD000', '51701-TD000', '51700-TD100', '51701-TD100', '52700-TD000', '52701-TD000', '49500-TD100', '49500-TD200', 
  '49600-XA000', '49601-XA000', '49560-DO000')


BOM %>% 
  group_by(차종, 구분, `FR/RR`, 완제품품번) %>% 
  summarise(
    판매가 = sum(부품수량 * 판매가),   # 부품수량과 판매가를 곱한 후 그룹별 합계 계산
    재료비 = sum(부품수량 * 재료비)    # 부품수량과 재료비를 곱한 후 그룹별 합계 계산
  ) %>% 
  mutate(완제품품번 = factor(완제품품번, levels = c_part_list)) %>% 
  arrange(완제품품번)

