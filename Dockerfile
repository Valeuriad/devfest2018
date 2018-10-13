# Debian + python 3.6 + data science essentials
FROM valeuriad/pythonds

MAINTAINER Nicolas Greffard "greffard.nicolas@valeuriad.fr"
ENV DEBIAN_FRONTEND noninteractive

# System deps
RUN apt-get -y -q update && \
    apt-get -y install \
               libcurl3 \
               libssl-dev \
               libcurl4-openssl-dev \
               libicu-dev \
               libxml2-dev \
               sudo \
               nano \
               supervisor \
               r-base \
               libpython-dev

# Python deps/libs
RUN pip install sklearn pandas flask flask-cors virtualenv

# R deps/libs
RUN R -e "install.packages(c(\
         'R6','tensorflow','plumber','shiny'),\
          repos = 'http://cran.us.r-project.org');\
          library(tensorflow);install_tensorflow();"

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
RUN apt-get install -y nodejs

# Install Angular
RUN npm install -g @angular/cli

# Bundle UI sources & deps
COPY pacman-ai /pacman-ai
COPY run_front.sh /
WORKDIR pacman-ai
RUN npm install
WORKDIR /

# Flask endpoint
RUN export FLASK_APP=app_ruler.py

# UI Port, R port & Python port
EXPOSE 4200
EXPOSE 4242
EXPOSE 5000

# Bundle game logic sources & data
COPY game_logic/src/* /
COPY game_logic/data /data

# Supervisor will keep all 3 services up & running
COPY supervisord.conf /etc/

# Train a new ruler : surprises are to be expected :)
RUN python train_ruler.py

# Start supervisor 
# it runs ng serve on the UI, R on the bot engine & python on the rule engine
CMD /usr/bin/supervisord