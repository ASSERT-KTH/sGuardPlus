FROM python:3.8

RUN apt-get update

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
    
RUN apt-get install -y nodejs    

WORKDIR /sGuardPlus

COPY slither_func2vec /sGuardPlus/slither_func2vec

COPY src /sGuardPlus/src

COPY utility /sGuardPlus/utility

COPY requirements.txt /sGuardPlus/requirements.txt

COPY package.json /sGuardPlus/package.json

COPY package-lock.json /sGuardPlus/package-lock.json

COPY run_on_smartbugs.py /sGuardPlus/run_on_smartbugs.py

RUN mkdir smartbugs

RUN mkdir results

RUN pip install -r requirements.txt && npm install

RUN solc-select install 0.4.26 && solc-select use 0.4.26

# ENTRYPOINT [ "nodejs", "src/index.js" ]