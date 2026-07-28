ARG EXIST_VERSION=release

FROM duncdrum/existdb:${EXIST_VERSION}

ADD https://github.com/BetaMasaheft/DillmannData/releases/latest/download/dill-data.xar /exist/autodeploy/001.xar

# roaster isn't bundled with the base image and the autodeploy trigger doesn't
# fetch missing dependencies over the network, so it has to be staged locally
ADD https://github.com/eeditiones/roaster/releases/download/v1.12.2/roaster-1.12.2.xar /exist/autodeploy/002-roaster.xar

COPY build/*.xar /exist/autodeploy/

# We might want to switch to exploded images for faster deployments later