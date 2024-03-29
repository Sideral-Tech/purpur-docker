#!/bin/bash

# This script is used to run the application

# Change to the server directory
cd /app/server || exit

# Set the JVM settings

JVM_SETTINGS="-Xoptionsfile=/app/config/config.jvm"

# Set Minecraft version

MC_VERSION=1.19.3

# Accept the EULA

echo "eula=true" > /app/server/eula.txt

# Setup directories

mkdir -p /app/server/plugins

# Download the latest Purpur build

wget https://api.purpurmc.org/v2/purpur/${MC_VERSION}/latest/download -O /app/server/purpur.jar

# Download the latest Geyser and Floodgate builds

# If you want to use a specific version, you can replace the lastSuccessfulBuild with the build number
wget https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/build/libs/Geyser-Spigot.jar -O /app/server/plugins/Geyser-Spigot.jar
wget https://ci.opencollab.dev/job/GeyserMC/job/Floodgate/job/master/lastSuccessfulBuild/artifact/spigot/build/libs/floodgate-spigot.jar -O /app/server/plugins/floodgate-spigot.jar

# Run the server
java --add-modules=jdk.incubator.vector ${JVM_SETTINGS} -jar -Dpaper.maxChunkThreads=4 /app/server/purpur.jar nogui
