rpi-docker-prestashop
===================

### Out-of-the-box LAMP image (PHP+MySQL+Prestashop) for Raspberry Pi (based Raspbian)


**Running your PRESTASHOP docker image**

Start your image binding the external ports 80 and 3306 in all interfaces to your container:

Command line first run

```
docker run -it --name prestadev -p 80:80 -p 3306:3306 --volume $(pwd)/presta-data/:/var/www/html websitedev/rpi-docker-prestashop
```
and let yourself be guided by the script

**Start your container**

```
docker start prestadev
```

# Build Details
- [Source Repository][df1]
- [Dockerfile][df2]

[df1]: <https://github.com/Prestaspirit/rpi-docker-prestashop>
[df2]: <https://github.com/Prestaspirit/rpi-docker-prestashop/blob/master/Dockerfile>