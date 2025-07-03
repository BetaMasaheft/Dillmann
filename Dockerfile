ARG EXIST_VERSION=release

FROM duncdrum/existdb:${EXIST_VERSION}

ADD https://github.com/BetaMasaheft/DillmannData/releases/latest/download/dill-data.xar /exist/autodeploy/001.xar

COPY build/*.xar /exist/autodeploy/

# We might want to switch to exploded images for faster deployments later