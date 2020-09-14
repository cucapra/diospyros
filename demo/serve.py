from flask import Flask, render_template, request
app = Flask(__name__)


@app.route('/')
def hello_world():
    return render_template('index.html', name='Diospyros')


@app.route('/compile', methods=['POST'])
def compile():
    return render_template(
        'index.html',
        name='Diospyros',
        result=('Received: ' + request.form['program']))
