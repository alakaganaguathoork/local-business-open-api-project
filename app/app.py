import os
from flask import (
    Flask,
    jsonify,
    redirect,
    Response
)

from app_logger import AppLogger
from rapidapi import RadipApi

APP_ENV = "local"

app = Flask(__name__)
logger = AppLogger()


@app.route("/")
#@logger.log
def root_path():
    """
    Root
    """
    return redirect("/rapid_api_search", code=302)

@app.route("/test")
@logger.log
def test_path():
    """
    Test
    """
    return Response("OK",
                    200,
                    {'Content-Type': 'text/plain'})

@app.route("/metrics")
@logger.log
def metrics():
    """
    Metrics for Prometheus

    not hidden for outside yet
    """
    return Response("",
                    status=200,
                    content_type="applicantion/text")

@app.route("/rapid_api_search")
@logger.log
def rapid_api_search():
    """
    Main endpoint
    """
    result = RadipApi.test_search()
    return Response(response=jsonify(result),
                    status=200,
                    content_type="application/json")


if __name__ == "__main__":
    APP_ENV = os.getenv("APP_ENV")
    HOST = "0.0.0.0"
    if APP_ENV == "local":
        PORT = "5400"
        print(f"+ + + Current environment is {APP_ENV} + + +")
        app.run(HOST, PORT, True)
