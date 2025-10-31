# Dockerfile to reproduce the GitHub Actions test job locally
FROM mambaorg/micromamba:1.5.6-bullseye

ENV MAMBA_CACHE_DIR=/tmp/mamba
# Activate the created environment for subsequent RUN instructions
ARG MAMBA_DOCKERFILE_ACTIVATE=1

WORKDIR /workspace

# Create the Conda environment defined in the repository
COPY environment.yml /tmp/environment.yml
RUN micromamba env create -f /tmp/environment.yml && \
    micromamba clean --all --yes
ENV MAMBA_DEFAULT_ENV=pgscen

# Copy the project into a temporary, writable build directory to avoid chown
# issues when source files are owned by the host. We'll install from the
# temp dir, then run tests using the environment.
COPY . /workspace

# Prepare writable locations: build workspace, mamba cache and a home dir for
# the mamba user. Copy sources into the temp build dir to avoid touching
# host-owned files. Chown the temp dirs to UID 1000 so the mamba user can use
# them without hitting permission errors or lockfile issues.
RUN mkdir -p /tmp/buildworkspace /tmp/mamba /home/mambauser && \
    cp -a /workspace/. /tmp/buildworkspace && \
    mkdir -p /home/mambauser/.cache/mamba && \
    chown -R 1000:1000 /tmp/buildworkspace /tmp/mamba /home/mambauser || true

# Expose HOME and MAMBA cache to ensure micromamba uses writable locations.
ENV HOME=/home/mambauser
ENV MAMBA_CACHE_DIR=/tmp/mamba

# Run pip install from the writable buildworkspace as UID 1000 so wheel
# building can create build/ directories without permission errors.
USER 1000
RUN bash -lc "MAMBA_CACHE_DIR=/tmp/mamba HOME=/home/mambauser TMPDIR=/tmp micromamba run -n pgscen pip install /tmp/buildworkspace"

# Run the test harness as the mamba user, ensuring mamba uses /tmp cache
CMD ["bash", "-c", "MAMBA_CACHE_DIR=/tmp/mamba HOME=/home/mambauser micromamba run -n pgscen bash test/test_run.sh"]
