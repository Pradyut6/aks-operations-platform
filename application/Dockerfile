FROM python:3.14-alpine@sha256:5862d971d1f0ae26b258cefa4e893556b1d3aba81bd2ff30888704ad378bab67

WORKDIR /app

COPY requirements.txt .

RUN python -m pip install --no-cache-dir -r requirements.txt \
    && python -m pip uninstall --yes pip \
    && rm -rf /usr/local/lib/python3.14/ensurepip

COPY app.py gunicorn.conf.py ./
COPY templates ./templates

USER 10001:10001

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]