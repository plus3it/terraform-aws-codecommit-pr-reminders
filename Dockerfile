FROM plus3it/tardigrade-ci:0.9.2

COPY ./src/requirements.txt /src/requirements.txt

RUN python -m pip install --no-cache-dir \
  -r /src/requirements.txt

WORKDIR /ci-harness
ENTRYPOINT ["make"]
