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

# Copy the project and install it the same way the workflow does
COPY . /workspace
RUN chown -R 1000:1000 /workspace
USER 1000
RUN micromamba run -n pgscen bash -c "MAMBA_CACHE_DIR=/tmp/mamba TMPDIR=/tmp pip install /workspace"

CMD ["bash", "-c", "MAMBA_CACHE_DIR=/tmp/mamba micromamba run -n pgscen bash test/test_run.sh"]
