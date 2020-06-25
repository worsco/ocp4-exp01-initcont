# -*- coding: UTF-8 -*-
"""
hello_flask: First Python-Flask webapp
"""
from flask import Flask, render_template
import os 
MYDATADIR = os.getenv('MYDATA_SOURCE_DIR')
MYTEMPLATESDIR = os.getenv('MYTEMPLATE_SOURCE_DIR')
app = Flask(__name__,
            static_url_path='',
            static_folder=MYDATADIR,
            template_folder=MYTEMPLATESDIR)

@app.route('/')
def main():
    return render_template('index.html')

if __name__ == '__main__':
    print("Hello World! Built with a Dockerfile.")
    app.run(host="0.0.0.0", port=8080, debug=True,use_reloader=True)
