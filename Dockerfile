FROM python:3.9-slim-buster
WORKDIR /app
COPY ./requirements.txt /app
RUN pip install --no-cache-dir -r requirements.txt
COPY ./app /app
COPY ./run.py /app/
EXPOSE 5000
ENV FLASK_APP=run.py
CMD ["flask", "run", "--host", "0.0.0.0"]