#!/bin/bash

# ------ SLURM Parameters ------

# rstudio-server is interactive.  Use the interactive partition
# Add cpu or memory slurm parameters as needed

#SBATCH -p interactive


# ------ cmd line input -------

# path to the singularity image
sif=$1

# path to the lib path to which /packages is
# mounted in the container. See the .Rprofile
# and the dockerfile for details
libpath=$2

# ------ Make sure it's run as a job ------

if [ -z "${SLURM_JOBID}" ]; then
    echo "Error: Must be run as a job"
    exit 1
fi

# ------ Load environment ------

eval $(spack load --sh singularityce@3.8.0)

# ------ Prep and run rstudio ------


unset XDG_RUNTIME_DIR
port=$(shuf -i9000-9999 -n1)
host=$(hostname)

TMPDIR=/tmp/rstudio-$USER-$SLURM_JOBID
mkdir ${TMPDIR}
mkdir ${TMPDIR}/data
mkdir ${TMPDIR}/db

cat <<EOF >$TMPDIR/rstudio-database.conf
provider=sqlite

# Directory in which the sqlite database will be written
directory=$TMPDIR/db
EOF

echo -e "
    In a local terminal, create SSH tunnel to $host
    -----------------------------------------------------------------
    ssh $USER@login.htcf.wustl.edu -N -L $port:$host:$port
    -----------------------------------------------------------------

    Go to the following address in a web browser
    -----------------------------------------------------------------
    http://localhost:$port
    -----------------------------------------------------------------
    "

# Launch rstudio server
singularity exec \
   -B $libpath:/packages \
   -B ${TMPDIR} \
   -B /scratch/<lab>/<your_scratch_dir> \
   -B /ref/<lab>/data \
   $sif \
   rserver \
     --www-port $port \
     --secure-cookie-key-file ${TMPDIR}/secure-cookie-key \
     --server-data-dir ${TMPDIR}/data \
     --server-pid-file ${TMPDIR}/rstudio.pid \
     --database-config-file ${TMPDIR}/rstudio-database.conf \
     --server-user=$USER
