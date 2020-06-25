# -*- coding: UTF-8 -*-
"""
hello_flask: First Python-Flask webapp
"""
from flask import Flask, render_template
app = Flask(__name__,
            static_url_path='',
            static_folder='/usr/share/html',
            template_folder='templates')

@app.route('/')
def main():
    return render_template('index.html')

if __name__ == '__main__':
    print("Hello World! Built with a Dockerfile.")
    app.run(host="0.0.0.0", port=8080, debug=True,use_reloader=True)
