FROM registry.redhat.io/rhscl/python-36-rhel7:1-66

WORKDIR /app
COPY . /app

RUN pip3 --no-cache-dir install -r requirements.txt

ENTRYPOINT ["sh"]
CMD ["initialize_pv.sh"]
