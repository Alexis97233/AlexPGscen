# Dockerfile to reproduce the GitHub Actions test job locally
FROM mambaorg/micromamba:1.5.6-bullseye

USER root

# Activate the created environment for subsequent RUN instructions
ARG MAMBA_DOCKERFILE_ACTIVATE=1

WORKDIR /workspace

# Create the Conda environment defined in the repository
COPY environment.yml /tmp/environment.yml
RUN micromamba env create -f /tmp/environment.yml && \
    micromamba clean --all --yes

# Copy the project and install it the same way the workflow does
COPY . /workspace
ENV MAMBA_USER=root
RUN mkdir -p /workspace/build && chmod -R a+rw /workspace/build
RUN PKG_CPPFLAGS="-DHAVE_WORKING_LOG1P" micromamba run -n pgscen Rscript -e 'install.packages(c("timeDate","quadprog","quantreg","plot3D","robustbase","scatterplot3d","splines","tseries","glasso","qgraph","reticulate","keras","rgl","glmnet"), repos="https://cloud.r-project.org")'
RUN micromamba run -n pgscen python -c "import zipfile; zipfile.ZipFile('/workspace/Rsafd.zip').extractall('/tmp')"
RUN micromamba run -n pgscen R CMD INSTALL /tmp/Rsafd
RUN micromamba run -n pgscen pip install .
RUN chown -R mambauser:mambauser /workspace
ENV MAMBA_USER=mambauser
USER mambauser

CMD ["micromamba", "run", "-n", "pgscen", "bash", "-c", "sh test/test_run.sh"]
