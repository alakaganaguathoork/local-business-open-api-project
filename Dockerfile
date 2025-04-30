FROM alpine:3.21.3

COPY app/ /app

RUN apk add python3 \
            py3-pip \
            py3-virtualenv

RUN python3 -m venv /env
RUN /env/bin/pip install --no-cache-dir -r /app/requirements.txt

ENV PATH="/env/bin/:$PATH"
ENV FLASK_DEBUG=1

#WORKDIR /app

EXPOSE 5400
ENTRYPOINT [ "python3" ]
CMD [ "/app/app.py" ]