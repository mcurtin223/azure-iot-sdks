FROM gcc

# the gcc image doesn't seem to have 'sudo' so
# we install it
RUN apt-get update && apt-get install -y sudo apt-utils vim

# add the sources to the image
ADD . /usr/src/azure-iot-sdks

# set current working dir to the c linux build folder
WORKDIR /usr/src/azure-iot-sdks/c/build_all/linux

# build proton and paho
RUN ["./setup.sh", "--quiet"]

# build the iot sdks
RUN ["./build.sh"]

# set working dir to root of repo
WORKDIR /usr/src/azure-iot-sdks
