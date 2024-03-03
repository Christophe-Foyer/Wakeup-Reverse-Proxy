FROM python:alpine

# Basic libraries
RUN apk add net-tools

# Set up the app
RUN mkdir /app
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY . .

CMD [ "python", "./app.py"]
