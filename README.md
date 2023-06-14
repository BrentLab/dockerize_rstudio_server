# Purpose

There can be some difficulty in running rstudio server on the HTCF -- one has to do with the compiled software paths that R relies on, another with controlling where R puts downloaded packages. Using a container addresses these issues.  

The container is configured so that you can mount a path into the container where any packages installed during an interactive session are saved. If you mount the same path from session to session, then you have a persistent software library. It also comes with most commonly used R software from CRAN and bioconductor pre-installed.

# Cite

This is an exact copy of David Tang's post here:

https://davetang.org/muse/2021/04/24/running-rstudio-server-with-docker/

instructions below are adapted for singularity

# Dockerfile

The dockerfile in this project loads the ubuntu system dependencies from 
Dave Tang's blog. I added R CRAN and Bioconductor dependencies. But, what 
is important is that you will be binding a system directory to the container so 
that any packages installed in the container will persist outside of it 
from session to session.

# Build and push

```sh
docker build -t <dockerhub username>/<image name> .
```

```sh
docker push <dockerhub username>/<image name>
```

# Singularity pull on the cluster

```sh

interactive

eval $(spack load --sh singularityce@3.8.0)

# you can fill in your own username/image name here, or feel free to 
# use mine
singularity pull docker://cmatkhan/htcf_rstudio_server
```

# submit via SBATCH

***Note***: Even afer the job launches and you get output in the SLURM log, you may have to wait a moment
for the container to start.

see the script in this project rstudio_singularity.sbatch

There are two cmd line arguments.

`$1`: path to the singularity image file

`$2`: path to the persistent library path. This will get bound to 
`/package` in the container and it is what will be the first path in the R 
`.libPaths()`. If you install a package while using rstudio in the container, 
it will be saved on the system (so it is persistent -- you won't have to 
reinstall packages every time you launch the container if you always provide 
the same path)

## example submission

```sh
sbatch --mem-per-cpu=10G -N 1 -n 5 --time=120 scripts/rstudio_singularity.sbatch software/htcf_rstudio_server_latest.sif $PWD/R/4.2/
```
