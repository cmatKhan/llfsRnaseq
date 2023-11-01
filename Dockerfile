# Use an official R base image
FROM rocker/r-ver:4.3.1

# Set maintainer label
LABEL maintainer="chasem@wustl.com"

# Install required system libraries
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libblas-dev \
    liblapack-dev \
    libgd-dev \
    gfortran \
    gzip \
    bzip2 \
    xz-utils \
    p7zip-full \
    libsqlite3-dev \
    libhdf5-dev \
    libbz2-dev \
    zlib1g-dev \
    libcairo2-dev \
    libxt-dev

# Install renv & dependencies
RUN R -e "install.packages('renv')"

# Create a directory for your project
WORKDIR /usr/local/src/my_project

# Copy your project files to the container (assuming they are in your current directory)
# This would typically include an renv.lock and renv/ directory if you have already snapshot your environment
COPY . .

# Restore the renv environment based on your lockfile
# RUN R -e 'renv::restore()'

# Expose port for RStudio or Shiny apps, if needed
# EXPOSE 8787

# Run a command to keep the container running, or specify a default action
CMD ["R"]
