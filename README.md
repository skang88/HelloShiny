# HelloShiny

This is first commint

Now I can commit everytime if there's any changes. 

# SAG Dashboard

KPI dashboard

# Commit From a laptop

Hi This is from Dell Latitude Laptop


# Run Docker container

docker stop shiny-container
docker rm shiny-container
docker build -t shiny-app .

# for production environment (without volume mount) - need to change dockerfile and decomment the COPY line
docker run -d -p 3838:3838 --name shiny-container --restart always shiny-app

# for development environment (with volume mount) - need to change dockerfile and comment the COPY line
# 그냥 개발은 Rstudio IDE 에서 하고, 테스트 및 배포는 production environment라고 생각하고 하는게 나은것 같음.
docker run -d -p 3838:3838 --name shiny-container -v $(pwd):/srv/shiny-server --restart always shiny-app
docker run -d -p 3838:3838 --name shiny-container -v C:/Users/admin/RProject/HelloShiny:/srv/shiny-server --restart always shiny-app




# 로그확인
docker exec -it shiny-container /bin/bash
cd var
cd log
cd shiny-server
