FROM python:3-alpine

WORKDIR /app
COPY . /app

RUN pip3 --no-cache-dir install -r requirements.txt

ENTRYPOINT ["sh"]
CMD ["initialize_pv.sh"]
