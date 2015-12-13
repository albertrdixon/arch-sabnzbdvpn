FROM binhex/arch-openvpn
MAINTAINER binhex

# additional files
##################

# add supervisor conf file for app
ADD *.conf /etc/supervisor/conf.d/

# add bash scripts to install app, and setup iptables, routing etc
ADD *.sh /root/

# add bash script to run sabnzbd
ADD apps/nobody/*.sh /home/nobody/

# install app
#############

# make executable and run bash scripts to install app
RUN chmod +x /root/*.sh /home/nobody/*.sh && \
	/bin/bash /root/install.sh

# docker settings
#################

# map /config to host defined config path (used to store configuration from app)
VOLUME /config

# map /downloads to host defined data path (used to store data from app)
VOLUME /downloads

# expose port for http
EXPOSE 8080

# expose port for https
EXPOSE 8090

# add docker-start
################
ADD docker-start /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-start

# run docker-start
CMD ["docker-start"]