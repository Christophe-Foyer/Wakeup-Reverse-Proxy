import os
import subprocess
from threading import Thread

import requests
from flask import Flask, Response, render_template, request
from ratelimit import RateLimitException, limits
from math import log10, floor
import logging

app = Flask(__name__, static_folder="templates/")

url = os.environ.get("DESTINATION_URL", "http://www.google.com")
print("Starting redirect server for url:", url)


def find_exp(number) -> int:
    base10 = log10(abs(number))
    return floor(base10)


command = os.environ.get("WAKE_CMD", None)
calls = float(os.environ.get("WAKE_CMD_MAX_FREQ", 1))
period = 1

exponent = min([find_exp(calls), 0])
period = 1*10**(-exponent)
calls = calls*10**(-exponent)

print("Wake command (max: {calls} calls / {period}s):", command)


def ignore_if_limited(f):
    def wrapper(*args, **kwargs):
        try:
            f(*args, **kwargs)
        except RateLimitException:
            pass

    return f


@ignore_if_limited
@limits(calls=int(calls), period=int(period))
def run_wake_routine():
    # Check for command
    if not command:
        raise RuntimeError("No 'WAKE_CMD' variable specified! Cannot run wake routine.")

    try:
        # Run command
        process = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            # check=True,
            text=True,
            shell=True,
        )

        # Print output
        print(process.stdout)
        print(process.stderr)
    except Exception as e:
        logging.exception(f"Exception running wake command | {e}")


def wake_if_off_route(func):
    def wake_if_off(*args, **kwargs):
        response_ok = False
        try:
            response = requests.get(url)
            if response.ok:
                response_ok = True
        except (requests.exceptions.HTTPError, requests.exceptions.ConnectionError):
            pass

        if not response_ok:
            Thread(target=run_wake_routine, daemon=True).start()
            return render_template("refresh.html", DESTINATION_URL=url)
        else:
            return func(*args, **kwargs)

    wake_if_off.__name__ = func.__name__
    return wake_if_off


@app.route('/', defaults={'path': ''})
@app.route('/<path:path>',methods=['GET','POST','DELETE'])
@wake_if_off_route
def proxy(path):
    if request.method=='GET':
        resp = requests.get(f'{url}{path}')
        excluded_headers = ['content-encoding', 'content-length', 'transfer-encoding', 'connection']
        headers = [(name, value) for (name, value) in  resp.raw.headers.items() if name.lower() not in excluded_headers]
        response = Response(resp.content, resp.status_code, headers)
        return response
    elif request.method=='POST':
        resp = requests.post(f'{url}{path}',json=request.get_json())
        excluded_headers = ['content-encoding', 'content-length', 'transfer-encoding', 'connection']
        headers = [(name, value) for (name, value) in resp.raw.headers.items() if name.lower() not in excluded_headers]
        response = Response(resp.content, resp.status_code, headers)
        return response
    elif request.method=='DELETE':
        resp = requests.delete(f'{url}{path}').content
        response = Response(resp.content, resp.status_code, headers)
        return response


if __name__ == "__main__":
    app.run(
        host="0.0.0.0", port=int(os.environ.get("WEBSERVER_PORT", 8080)), debug=True
    )
