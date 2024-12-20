# Base image
FROM rocker/shiny:4.3.1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libxml2-dev \
    libssl-dev \
    libmariadb-dev \
    libmariadb-dev-compat \
    mariadb-client \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install required R packages
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'shinydashboardPlus', 'plotly', 'DBI', 'RMariaDB', 'ggplot2', 'dplyr', 'tidyr', 'DT', 'dotenv'), dependencies=TRUE, repos='https://cloud.r-project.org/')"

# Copy current directory to the image
# Comment for development environment
COPY . /srv/shiny-server/

# Set permissions for Shiny app
RUN chown -R shiny:shiny /srv/shiny-server && chmod -R 755 /srv/shiny-server

# Expose the port for the Shiny app
EXPOSE 3838

# Start Shiny Server
CMD ["/usr/bin/shiny-server"]
