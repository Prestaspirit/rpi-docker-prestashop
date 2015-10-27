rpi-docker-prestashop
===================

####  Out-of-the-box LAMP image (PHP+MySQL+Prestashop) for Raspberry Pi (based Raspbian)

Running your PRESTASHOP docker image

Start your image binding the external ports 80 and 3306 in all interfaces to your container:

Command line first run

```

docker run -it --name prestadev -p 80:80 -p 3306:3306 --volume $(pwd)/presta-data/:/var/www/html websitedev/rpi-docker-prestashop

```

Start your container

```

docker start prestadev

```

