import subprocess
from flask import Flask, request

app = Flask(__name__)

def compile(reponse):
    program = reponse['message']
    with open("tmp.c", "w") as text_file:
        text_file.write(program)
    # cmd = subprocess.run(['racket', '../src/c-meta.rkt'], stdout=subprocess.PIPE)
    cmd = subprocess.run(['python3', 'compile.py'], stdout=subprocess.PIPE)
    return cmd.stdout


@app.route('/api/', methods=["POST"])
def main_interface():
    response = request.get_json()
    return compile(response)


@app.after_request
def add_headers(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers',
                         'Content-Type,Authorization')
    return response


if __name__ == '__main__':
    app.run(debug=True)
