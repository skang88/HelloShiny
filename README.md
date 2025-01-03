# SAG Dashboard

Hi This is KPI dashboard.


# How to run Docker container
docker build -t shiny-app .
docker stop shiny-container
docker rm shiny-container


# for production environment (without volume mount) - need to change dockerfile and decomment the COPY line
docker run -d -p 3838:3838 --name shiny-container --restart always shiny-app



# for development environment (with volume mount) - need to change dockerfile and comment the COPY line
# 개발 환경에서 app.R 파일을 볼륨에 마운트하여 개발하면서 업데이트 되도록 할 수 있지만, 
# 프로덕션 환경처럼 볼륨에 마운트하지 않고 그대로 이미지를 만들어서 배포하는게 더 나은 선택일 수 있음. 
# 그냥 개발은 Rstudio IDE 에서 하고, 테스트 및 배포는 production environment라고 생각하고 하는게 나은것 같음.
# docker run -d -p 3838:3838 --name shiny-container -v $(pwd):/srv/shiny-server --restart always shiny-app
# docker run -d -p 3838:3838 --name shiny-container -v C:/Users/admin/RProject/HelloShiny:/srv/shiny-server --restart always shiny-app




# 로그확인
docker exec -it shiny-container /bin/bash
cd var
cd log
cd shiny-server
