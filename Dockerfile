FROM ubuntu:bionic

LABEL maintainer="Ralf Geschke <ralf@kuerbis.org>"

LABEL last_changed="2019-05-13"

# necessary to set default timezone Etc/UTC
ENV DEBIAN_FRONTEND noninteractive 

# mostly taken from https://github.com/cjhardekopf/docker-duplicity/blob/master/Dockerfile

RUN apt-get update \
    && apt-get -y install software-properties-common \
    && add-apt-repository -y ppa:duplicity-team/ppa \
    && apt-get update \
    && apt-get -y upgrade \
	&& apt-get -y dist-upgrade \
	&& apt-get install -y ca-certificates \
	&& apt-get install -y --no-install-recommends \
	&& apt-get install -y locales \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && apt-get -y install python-boto python-paramiko python-pycryptopp lftp librsync1 duplicity \
    && mkdir -p /var/log/duplicity \
    && rm -rf /var/lib/apt/lists/*


COPY backup.sh /usr/local/bin/
COPY restore.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/*.sh

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["help"]

