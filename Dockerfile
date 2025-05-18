FROM julia:1.11
RUN useradd --create-home --shell /bin/bash genie
USER genie
RUN mkdir /home/genie/app
WORKDIR /home/genie/app
COPY --chown=genie:genie . . 
EXPOSE 8000
EXPOSE 80
ENV JULIA_DEPOT_PATH="/home/genie/.julia"
ENV JULIA_REVISE="off"
ENV GENIE_ENV="prod"
ENV GENIE_HOST="0.0.0.0"
ENV PORT="8000"
ENV WSPORT="8000"
ENV EARLYBIND="true"
RUN julia -e "using Pkg; Pkg.activate(\".\"); Pkg.instantiate(); Pkg.precompile();"
HEALTHCHECK --interval=120s --timeout=3s CMD curl --fail http://localhost:8000 || exit 1
ENTRYPOINT ["julia", "--project", "-e", "using GenieFramework; Genie.loadapp(); up(async=false);"]
