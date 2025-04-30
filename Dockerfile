FROM alpine:3.21.3
WORKDIR /app

ENV PATH="/env/bin/:$PATH"
ENV FLASK_DEBUG=1

RUN apk add python3 \
    py3-pip \
    py3-virtualenv

COPY app/ .
RUN python3 -m venv /env
RUN /env/bin/pip install --no-cache-dir -r ./requirements.txt

EXPOSE 5400
ENTRYPOINT [ "python3" ]
CMD [ "app.py" ]