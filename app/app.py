import asyncio
import os
from flask import ( 
    Flask, 
    jsonify,
    redirect
)

from app_logger import AppLogger
from rapidapi import RadipApi

app = Flask(__name__)
logger = AppLogger()
APP_ENV = "local"

@app.route("/")
#@logger.log
def root_path():
    return redirect("/rapid_api_search", code=302)

@app.route("/rapid_api_search")
@logger.log
def rapid_api_search():
    result = RadipApi.test_search()
    return jsonify(result)


if __name__ == "__main__":
    APP_ENV = os.getenv("APP_ENV")
    print(f"Current environment is ${APP_ENV}")

    if APP_ENV == "local":
        host = "0.0.0.0"
        port = 5400
        asyncio.run(app.run(host, port, True))