#!/bin/bash

# Install Dependencies for Compiling SWG
printf "\nInstalling Dependencies for Compiling SWG\n"
sudo zypper refresh
sudo zypper install -y ant clang bison flex cmake \
    libaio-32bit libgcc_s1-32bit glibc-32bit glibc-devel-32bit \
    libstdc++6-devel-gcc11-32bit ncurses-devel-32bit \
    libxml2-devel libxml2-devel-32bit \
    libpcre1-devel libpcre1-devel-32bit \
    libcurl4-32bit libcurl-devel libcurl-devel-32bit \
    boost-devel boost-devel-32bit \
    sqlite3-devel sqlite3-devel-32bit libnsl-32bit

# Create and navigate to dependencies directory
mkdir -p ~/swg_dependencies
cd ~/swg_dependencies

# Download and install Boost 1.85.0
printf "\nDownloading and Installing Boost 1.85.0\n"
wget https://boostorg.jfrog.io/artifactory/main/release/1.85.0/source/boost_1_85_0.zip
unzip boost_1_85_0.zip
cd boost_1_85_0/
./bootstrap.sh
sudo ./b2 install

# Set Environment Variables
printf "\nSetting Environment Variables\n"
sudo bash -c 'echo "/usr/lib/oracle/18.3/client/lib" > /etc/ld.so.conf.d/oracle.conf'
sudo bash -c 'cat > /etc/profile.d/oracle.sh <<EOF
export ORACLE_HOME=/usr/lib/oracle/18.3/client
export PATH=\$PATH:/usr/lib/oracle/18.3/client/bin
export LD_LIBRARY_PATH=/usr/lib/oracle/18.3/client/lib:/usr/include/oracle/18.3/client
EOF'

sudo ln -sf /usr/include/oracle/18.3/client $ORACLE_HOME/include
sudo ldconfig

# Set Java Environment Variables
printf "\nSetting Java Environment Variables\n"
sudo bash -c 'cat > /etc/profile.d/java.sh <<EOF
export JAVA_HOME=/usr/lib/jvm/zulu-17-x86
EOF'

# Download and Install Azul Java 17
printf "\nDownloading and Installing Azul Java 17\n"
wget https://cdn.azul.com/zulu/bin/zulu17.50.19-ca-jdk17.0.11-linux.i686.rpm
sudo zypper install -y ./zulu17.50.19-ca-jdk17.0.11-linux.i686.rpm

# Install Additional Dependencies for 32-bit Libraries
printf "\nInstalling Additional 32-bit Dependencies\n"
sudo zypper install -y libXext6-32bit libXrender1-32bit libXtst6-32bit

# Install Alien, PHP, and PHP OCI8
printf "\nInstalling Alien, PHP, and PHP OCI8\n"
sudo zypper install -y alien php7 php7-pear php7-devel libaio1

# Install PHP OCI8 Extension
echo "instantclient,/usr/lib/oracle/18.3/client/lib" | sudo pecl install oci8

# Add OCI8 Extension to PHP Configuration
echo "extension=oci8.so" | sudo tee -a /etc/php7/cli/php.ini
echo "extension=oci8.so" | sudo tee -a /etc/php7/apache2/php.ini

# Set Oracle Environment Variables for Apache2
sudo bash -c 'cat >> /etc/apache2/envvars <<EOF
export ORACLE_HOME=/usr/lib/oracle/18.3/client
export LD_LIBRARY_PATH=/usr/lib/oracle/18.3/client/lib
EOF'

# Restart Apache2
sudo systemctl restart apache2

printf "\nSWG Dependencies Installation Completed Successfully!\n"
