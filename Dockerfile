FROM plus3it/tardigrade-ci:0.13.0

COPY ./src/requirements.txt /src/requirements.txt

RUN python -m pip install --no-cache-dir \
  -r /src/requirements.txt

WORKDIR /ci-harness
ENTRYPOINT ["make"]
