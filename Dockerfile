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

# Create a writable build workspace and switch ownership to the mamba user
RUN mkdir -p /tmp/buildworkspace && \
    cp -a /workspace/. /tmp/buildworkspace && \
    chown -R 1000:1000 /tmp/buildworkspace /tmp/mamba || true

# Run pip install from the writable buildworkspace as UID 1000 so wheel
# building can create build/ directories without permission errors.
USER 1000
RUN micromamba run -n pgscen bash -c "MAMBA_CACHE_DIR=/tmp/mamba TMPDIR=/tmp pip install /tmp/buildworkspace"

# Run the test harness as the mamba user, ensuring mamba uses /tmp cache
CMD ["bash", "-c", "MAMBA_CACHE_DIR=/tmp/mamba micromamba run -n pgscen bash test/test_run.sh"]
