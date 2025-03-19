import asyncio
from flask import Flask, jsonify, redirect

from rapidapi import RAPIDAPI

app = Flask(__name__)

@app.route("/")
def root_path():
#    return jsonify({"message": "Welcome to the API!"})
    return redirect("/rapid_api_search", code=302)

@app.route("/rapid_api_search")
def rapid_api_search():
    result = RAPIDAPI.test_search()
    return jsonify(result)


if __name__ == "__main__":
    host = "0.0.0.0"
    port = 5400
    asyncio.run(app.run(host, port, True))