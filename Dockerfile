FROM ubuntu:18.04
ENV LANG C.UTF-8
ARG PROJECT=project
RUN export DEBIAN_FRONTEND=noninteractive
RUN apt update && apt upgrade -y

RUN apt install -y sudo
RUN apt install -y tzdata
RUN ln -fs /usr/share/zoneinfo/America/Lima /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN apt install wget -y
RUN apt install python3 -y
RUN apt install python3-pip -y
RUN apt install tar -y
RUN pip3 install num2words xlwt

RUN wget -O - https://nightly.odoo.com/odoo.key | apt-key add -
RUN echo "deb http://nightly.odoo.com/12.0/nightly/deb/ ./" >> /etc/apt/sources.list.d/odoo.list
RUN apt update && apt-get install odoo -y

RUN apt install libxrender1 -y
RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN tar -xvf wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN rm -f /usr/local/bin/wkht* \
        && rm -f /usr/bin/wkht* \
        && cp -r wkhtmltox/bin/* /usr/local/bin/ \
        && cp -r wkhtmltox/bin/* /usr/bin/ 

RUN set -x; \
        echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' > etc/apt/sources.list.d/pgdg.list \
        && export GNUPGHOME="$(mktemp -d)" \
        && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
        && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
        && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
        && gpgconf --kill all \
        && rm -rf "$GNUPGHOME" \
        && apt-get update  \
        && apt-get install -y postgresql-client \
        && rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /
COPY ./requirements.txt /

RUN mkdir -p /mnt/${PROJECT} \
        && chown -R odoo /mnt/${PROJECT}
RUN mkdir -p /mnt/${PROJECT}_utils \
        && chown -R odoo /mnt/${PROJECT}_utils
VOLUME ["${PROJECT}", "/mnt/${PROJECT}"]

RUN pip3 install -r requirements.txt
RUN adduser --system --home=/opt/odoo --group odoo

EXPOSE 8069


USER odoo
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo", "-c/etc/odoo/odoo.conf"]
# CMD ["bash"]
