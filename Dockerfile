FROM ubuntu:14.04
MAINTAINER Peter Frey<freypa22@gmail.com>
EXPOSE 80 22 4730 5666

ENV REFRESHED 2015-11-16
ENV CUSTOMIZED 2016-02-13

RUN  echo 'net.ipv6.conf.default.disable_ipv6 = 1' > /etc/sysctl.d/20-ipv6-disable.conf; \ 
    echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.d/20-ipv6-disable.conf; \ 
    echo 'net.ipv6.conf.lo.disable_ipv6 = 1' >> /etc/sysctl.d/20-ipv6-disable.conf; \ 
    cat /etc/sysctl.d/20-ipv6-disable.conf; sysctl -p

RUN gpg --keyserver keys.gnupg.net --recv-keys F8C1CA08A57B9ED7 && \
    gpg --armor --export F8C1CA08A57B9ED7 | apt-key add - 

RUN echo "deb http://labs.consol.de/repo/stable/ubuntu $(lsb_release -sc) main" >> /etc/apt/sources.list && \
    apt-get update

# http://omdistro.org/doc/quickstart_debian_ubuntu
RUN apt-get install -y lsof vim git openssh-server tree tcpdump libevent-2.0-5 
RUN apt-get install -y xinetd  

#RUN apt-get install -y omd-labs-edition
# troubles, get thruk but no check-mk gui, unfortunately
#
# http://mathias-kettner.com/cms_install_packages.html 
# http://mathias-kettner.com/check_mk_news.html
# http://mathias-kettner.com/check_mk_download_version.php?HTML=&version=1.2.6p16&edition=cre
# http://mathias-kettner.com/cms_install_packages.html
# 
RUN apt-get install gdebi-core
ENV cmk-distro check-mk-raw-1.2.6p16_0.$(lsb_release -sc}_amd64.deb
# vs _i368.deb ?
RUN gdebi $cmk-distro


RUN a2enmod proxy_http

RUN sed -i 's|echo "on"$|echo "off"|' /opt/omd/versions/default/lib/omd/hooks/TMPFS

RUN omd create cmkfrey || true

# https://monitoring-portal.org/index.php?thread/28386-site-konfiguration-via-skript/&s=9c8d12a866a4602ba59378468f2afc0b8df77196
RUN omd config cmkfrey set DEFAULT_GUI check_mk

RUN omd config cmkfrey set APACHE_TCP_ADDR 0.0.0.0

RUN echo 'root:frpadmin' | chpasswd
RUN echo 'cmkfrey:freycmk' | chpasswd

#ENV OMD_DEMO /opt/omd/sites/demo
ENV OMD_DEMO /opt/omd/sites/cmkfrey

ADD run_omd.sh /run_omd.sh
CMD ["/run_omd.sh"]
