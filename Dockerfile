FROM python:3.8

RUN apt-get update

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -

RUN apt-get install -y nodejs

ADD . /sGuardPlus

WORKDIR /sGuardPlus

RUN pip install -r requirements.txt && npm install

RUN solc-select install 0.4.26 && solc-select use 0.4.26

ENTRYPOINT [ "nodejs", "src/index.js" ]