FROM trusty
RUN sudo apt-get update && DEBIAN_FRONTEND=noninteractive sudo -E apt-get install -y php5 apache2 && sudo apt-get clean

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

EXPOSE 80

# the website
RUN rm /var/www/html/index.html
ADD html/ /var/www/html/

# By default, simply start apache.
CMD /usr/sbin/apache2ctl -D FOREGROUND
