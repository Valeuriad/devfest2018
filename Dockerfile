FROM valeuriad/pythonds

MAINTAINER Nicolas Greffard "greffard.nicolas@valeuriad.fr"
ENV DEBIAN_FRONTEND noninteractive

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

RUN pip install sklearn pandas flask flask-cors virtualenv


RUN R -e "install.packages(c(\
         'R6','tensorflow','plumber','shiny'),\
          repos = 'http://cran.us.r-project.org');\
          library(tensorflow);install_tensorflow();"


RUN curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
RUN apt-get install -y nodejs

RUN npm install -g @angular/cli

COPY pacman-ai /pacman-ai
COPY run_front.sh /
WORKDIR pacman-ai
RUN npm install
WORKDIR /

RUN export FLASK_APP=app_ruler.py

EXPOSE 4200
EXPOSE 4242
EXPOSE 5000

COPY game_logic/src/* /
COPY game_logic/data /data
COPY supervisord.conf /etc/

RUN python train_ruler.py

CMD /usr/bin/supervisord