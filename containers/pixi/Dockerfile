ARG CUDA_VERSION="12.9"
ARG ENVIRONMENT="default"

FROM ghcr.io/prefix-dev/pixi:noble AS build

# Redeclaring ARGS in a stage without a value inherits the global default
ARG CUDA_VERSION
ARG ENVIRONMENT

WORKDIR /app
COPY . .
ENV CONDA_OVERRIDE_CUDA=$CUDA_VERSION
RUN pixi install --locked --environment $ENVIRONMENT
# Activate ENVIRONMENT at container runtime by using the Pixi environment
# activation script as the container ENTRYPOINT
# Batch systems (e.g. HTCondor's container universe) run the container as a
# host uid with no /etc/passwd entry and a scrubbed environment, so
# getpass.getuser() raises OSError (e.g. at 'import torch' time when
# resolving the torchinductor cache dir). Export fallback USER and LOGNAME
# so getpass.getuser() never needs the passwd database.
# Similarly, HOME defaults to the unwritable '/' for uids without a passwd
# entry, which breaks anything writing to ~/.cache (torch hub, matplotlib,
# fontconfig), so fall back to a writable temporary directory.
RUN echo "#!/usr/bin/env bash" > /app/entrypoint.sh && \
    echo 'export USER="${USER:-$(id -u)}"' >> /app/entrypoint.sh && \
    echo 'export LOGNAME="${LOGNAME:-$USER}"' >> /app/entrypoint.sh && \
    echo '[ -w "${HOME:-/}" ] || export HOME="$(mktemp -d)"' >> /app/entrypoint.sh && \
    pixi shell-hook --environment $ENVIRONMENT --shell bash >> /app/entrypoint.sh && \
    echo 'exec "$@"' >> /app/entrypoint.sh

FROM ghcr.io/prefix-dev/pixi:noble AS final

ARG ENVIRONMENT

WORKDIR /app
COPY --from=build /app/.pixi/envs/$ENVIRONMENT /app/.pixi/envs/$ENVIRONMENT
COPY --from=build /app/pixi.toml /app/pixi.toml
COPY --from=build /app/pixi.lock /app/pixi.lock
# The ignore files are needed for 'pixi run' to work in the container
COPY --from=build /app/.pixi/.gitignore /app/.pixi/.gitignore
COPY --from=build /app/.pixi/.condapackageignore /app/.pixi/.condapackageignore
COPY --from=build --chmod=0755 /app/entrypoint.sh /app/entrypoint.sh

ENTRYPOINT [ "/app/entrypoint.sh" ]
