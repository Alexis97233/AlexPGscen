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

# Ensure mamba cache and HOME are writable by root (we'll run install & tests as root)
RUN mkdir -p /tmp/mamba && chown -R root:root /tmp/mamba || true
ENV HOME=/root
ENV MAMBA_CACHE_DIR=/tmp/mamba

# Install the package from the image workspace as root. This avoids chown
# operations on host-owned files and ensures wheel building has permissions.
RUN bash -lc "TMPDIR=/tmp micromamba run -n pgscen pip install /workspace"

# Run the test harness inside the container (as root). Using root avoids
# cross-user lockfile issues with mamba on macOS/GitHub Actions runners.
CMD ["bash", "-c", "MAMBA_CACHE_DIR=/tmp/mamba HOME=/root micromamba run -n pgscen bash test/test_run.sh"]
