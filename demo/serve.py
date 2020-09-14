from flask import Flask, render_template, request
app = Flask(__name__)

@app.route('/')
def hello_world():
    return render_template('index.html', name='Rachit')

@app.route('/compile', methods=['POST'])
def compile():
    print('Received: ' + request.form['text'])
    return '', 204
