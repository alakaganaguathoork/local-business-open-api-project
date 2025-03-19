FROM alpine:3.21.3

COPY app/ /app
COPY .env .env

RUN apk add python3 py3-pip py3-virtualenv

RUN python3 -m venv /env
RUN /env/bin/pip install --no-cache-dir -r app/requirements.txt

ENV PATH="/env/bin/:$PATH"
#ENV X_RAPIDAPI_KEY=${X_RAPIDAPI_KEY}

WORKDIR /app

EXPOSE 5400
ENTRYPOINT [ "python3" ]
CMD [ "app.py" ]