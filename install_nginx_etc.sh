#!/bin/bash

sudo apt-get -y update
sudo apt-get -y install nginx

sudo echo '<html><title>Cisco SPL</title><body><h2 align="center">Cisco SPL</body></html>' > /var/www/html/index.html
sudo echo '<html><title>Health Page</title><body><p>Alive!</body></html>' > /var/www/html/health.html

sudo service nginx start
