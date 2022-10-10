## Demonstration of a GIS enabled digital Library using Docker, PostgreSQL, PostGIS and Adminer

### Navigation
  - [Introduction](#introduction)
  - [Directory Structure](#directory-structure)
    - [Data](#data)
    - [Db](#db)
    - [Images](#images)
    - [Tests](#tests)
  - [Setup](#setup)

## Directory Structure
## Data
This directory contains the data to be uploaded into the digital library

## Db
This directory contains the sql codes (<b>init.sql</b>) that needs to be executed at the initialization of the Postgres docker container

## Images
This directory contains the image data model.

## Test
This directory contains scripts for testing.

## Introduction
<p>A firm wants a brief demo on the processes of building a GIS enabled digital library and the benefits they can gain from having such an infrastrature.</br>

This project seeks to achieve the following
    <ol>
        <li>Design a simple GIS enabled database</li>
        <li>Simulate a cloud database with a docker container</li>
        <li>Establish a connection betwwen the database in the docker container and user machine</li>
        <li>Populate the database using a Dockerfile and a python script</li>
        <li>Create a database service to which open source GIS tools can connect and access content</li>
        <li>Run a script to execute a query which answers a GIS related question</li>
    </ol>

### Designed model
<img src="images/data_model.png">
</br>
</br>

## Setup
Docker must be installed before this project can be run.
This project was built on Ubuntu therefore the terminal scripts will not run on a non unix os. It is recommended that it is ran on a ubuntu

Clone the repository and create a pthon virtual environment.

There is a point in the <b>demo.py</b> script where a .shp file is loaded into the digital library. This will not be possible if you dont have PostGIS installed. This is because it uses <b>shp2pgsql</b>, a command line tool that comes with PostGIS.

Run the code below in the terminal in the home directory of the repository to build and start the docker containers with PostgreSQL and PostGIS to simulate the cloud digital library service
```
docker-compose up -d --build
```

Follow this up with the codes bellow.

The output answers the question,

### How many restaurants (franchises) are within a distance of one mile from the principal streets of U S A

```
pip install -r requirements.txt
python demo.py
```
</p>