FROM python:3-alpine

WORKDIR /app
COPY . /app

RUN pip3 --no-cache-dir install -r requirements.txt

EXPOSE 8080

ENTRYPOINT ["python3"]
CMD ["helloworld.py"]
