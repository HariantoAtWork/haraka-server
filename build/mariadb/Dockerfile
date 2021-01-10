FROM mariadb

ENV TERM=linux
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y --no-install-recommends nano

ADD init-user-db.sh /docker-entrypoint-initdb.d/
