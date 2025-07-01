ARG EXIST_VERSION=release
ARG BUILD=local

FROM duncdrum/existdb:${EXIST_VERSION}

ADD https://github.com/BetaMasaheft/DillmannData/releases/latest/download/dill-data-3.0.1.xar /exist/autodeploy/001.xar

COPY build/*.xar /exist/autodeploy/

# https://github.com/BetaMasaheft/DillmannData/releases/download/v3.0.1/dill-data-3.0.1.xar