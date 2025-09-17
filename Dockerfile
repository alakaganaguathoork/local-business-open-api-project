FROM alpine:latest
WORKDIR /app

ENV PATH="/env/bin/:$PATH"
ENV FLASK_DEBUG=1

RUN apk add curl \
            nano \
            python3 \
            py3-pip \
            py3-virtualenv

COPY app/ .

RUN python3 -m venv /env
RUN /env/bin/pip install --no-cache-dir -r requirements.txt

RUN find . -name '__pycache__' -exec rm -rf {} + && \
    find . -name '*.dist-info' -exec rm -rf {} +

EXPOSE 5400
ENTRYPOINT [ "python" ]
CMD [ "app.py" ]