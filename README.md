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

# for development environment
docker run -d -p 3838:3838 --name shiny-container -v $(pwd):/srv/shiny-server --restart always shiny-app
docker run -d -p 3838:3838 --name shiny-container -v C:/Users/admin/RProject/HelloShiny:/srv/shiny-server --restart always shiny-app




# 로그확인
docker exec -it shiny-container /bin/bash
cd var
cd log
cd shiny-server
