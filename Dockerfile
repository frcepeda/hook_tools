FROM ubuntu:focal

MAINTAINER Luis Héctor Chávez <lhchavez@omegaup.com>

RUN ln -snf /usr/share/zoneinfo/Etc/UTC /etc/localtime && echo Etc/UTC > /etc/timezone
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl \
        git \
        locales \
        php-pear \
        php7.4-cli \
        php7.4-json \
        php7.4-mbstring \
        php7.4-xml \
        python3-pip \
        python3-setuptools \
        python3-six
RUN /usr/sbin/locale-gen en_US.UTF-8 && /usr/sbin/update-locale LANG=en_US.UTF-8

# Python support.
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install \
        pylint==2.5.3 \
        pycodestyle==2.6.0 \
        Jinja2==2.11.2 \
        pyparsing==2.4.7 \
        mypy==0.770
RUN mkdir -p /.pylint.d && chown 1000:1000 /.pylint.d

# PHP support.
RUN curl --location \
        https://github.com/squizlabs/PHP_CodeSniffer/releases/download/3.5.6/phpcbf.phar \
        --output /usr/bin/phpcbf && \
    chmod 755 /usr/bin/phpcbf
RUN curl --location \
        https://github.com/squizlabs/PHP_CodeSniffer/releases/download/3.5.6/phpcs.phar \
        --output /usr/bin/phpcs && \
    chmod 755 /usr/bin/phpcs

# JavaScript support.
RUN git clone https://github.com/creationix/nvm.git /nvm
RUN (cd /nvm && git checkout `git describe --abbrev=0 --tags`)
RUN (. /nvm/nvm.sh && nvm install v12.18.2 ; nvm use --delete-prefix v12.18.2)
ENV PATH="/usr/bin/versions/node/v12.18.2/bin:${PATH}"
RUN npm install -g yarn
RUN yarn global add prettier@2.1.2 prettier-plugin-karel@1.0.2
RUN mkdir -p /.yarn /.cache && chown 1000:1000 /.yarn /.cache

RUN mkdir -p /src
WORKDIR /src

ENV DOCKER=true
ENV LANG=en_US.UTF-8

RUN mkdir -p /hook_tools
ADD ./ /hook_tools

USER 1000
ENTRYPOINT ["/usr/bin/python3", "/hook_tools/lint.py"]
