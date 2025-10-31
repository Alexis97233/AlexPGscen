# Dockerfile to reproduce the GitHub Actions test job locally
FROM mambaorg/micromamba:1.5.6-bullseye

# Activate the created environment for subsequent RUN instructions
ARG MAMBA_DOCKERFILE_ACTIVATE=1

WORKDIR /workspace

# Create the Conda environment defined in the repository
COPY environment.yml /tmp/environment.yml
RUN micromamba env create -f /tmp/environment.yml && \
    micromamba clean --all --yes

# Copy the project and install it the same way the workflow does
COPY --chown=root:root . /workspace
RUN micromamba run -n pgscen pip install .

CMD ["micromamba", "run", "-n", "pgscen", "bash", "test/test_run.sh"]
