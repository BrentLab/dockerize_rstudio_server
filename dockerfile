FROM rocker/rstudio:4.2.2

MAINTAINER chase mateusiak <chasem@wustl.edu>

RUN apt-get clean all && \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y \
    libhdf5-dev \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev \
    libpng-dev \
    libxt-dev \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libglpk40 \
    libgit2-dev \
    libpq-dev \
    libssl-dev \
    curl \
    wget \
  && apt-get clean all && \
  apt-get purge && \
  apt-get autoremove && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN Rscript -e "install.packages(c('usethis', 'devtools', 'remotes', 'renv', 'future', 'doFuture', 'furrr', 'future.batchtools', 'future.callr', 'future.apply', 'progressr', 'future.tests', 'parallelly', 'RPostgres', 'rmarkdown', 'tidyverse', 'workflowr','BiocManager', 'usethis', 'ggplot2','RSQLite', 'readxl', 'here', 'vroom', 'caret', 'broom', 'ggsci', 'DT', 'TidyMultiqc'), Ncpus=10);"
RUN Rscript -e "BiocManager::install(version = '3.21')"
RUN Rscript -e "BiocManager::install(c('Biobase', 'DESeq2', 'tximport', 'edgeR'), Ncpus=10)"


#COPY user-settings /home/rstudio/.rstudio/monitored/user-settings/user-settings
COPY .Rprofile /home/rstudio/
