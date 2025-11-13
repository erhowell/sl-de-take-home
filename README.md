# SL/VF Data Engineer Technical Take Home

> Build is a mini ELT pipeline that extracts recent NYC traffic collision data, loads it into a database, transforms it into an analytical table, and produces a summary CSV

- [Evaluation](#evaluation)
- [What we are looking for](#what-we-are-looking-for)
- [Submitting your code](#submitting-your-code)
- [Questions or Concerns](#questions-or-concerns)
- [Running the code](#running-the-code)


## Evaluation

For this exercise you will be expected to:

1. Extracts recent collision data from NYC Open Data API
    - [Collision Crashes](https://data.cityofnewyork.us/Public-Safety/Motor-Vehicle-Collisions-Crashes/h9gi-nx95)
    - [Collision Vehicles](https://data.cityofnewyork.us/Public-Safety/Motor-Vehicle-Collisions-Vehicles/bm4k-52h4/about_data)
    - [Collision Persons](https://data.cityofnewyork.us/Public-Safety/Motor-Vehicle-Collisions-Person/f55k-p6yu/about_data)
2. Loads the raw data into a local Postgres database 
3. Complete Transforms listed in the transforms deirectory
4. Directly query transforms from a Jupyter notebook and display the data in a meaningful way. You can use the notebook provided as a blueprint, or you can do your own thing.

We have provided starter code. Feel free to use it or do your own thing. If you decide to use different technologies than what is provided please leave detailed instructions on how to run your project in a README during submission


## What we are looking for

- Does it work?
- How complete is your project? If you are unable to complete part of the assessment explain why
- Is the code clean and accessible to others?
- SQL and python knowlege 


## Time Limit

The purpose of the test is not to measure the speed of code creation. Please try to finish within 5 days of being sent the code test, but extra allowances are fine and will not be strictly penalized.

## Submitting Your Code

The preferred way to submit your code is to create a fork of this repo, push your changes to the forked repo, and then either:
- open a pull request against the original repo from your forked repo
- grant access to your forked repo to erhowell, so that we can access the code there.
Alternatively, you may submit the code in the form of a zip file and send it to erhowell@swingleft.org. 

Please be sure to include a README in your submission with full details on how to set up and run your code as well as answer the following questions:
- Roughly how long did this project take you
- How you felt about this project, and what issues did you face, if any.  

Speed is not what we are evaluating; we are evaluating the process as a whole and the effort it takes to complete it.


## Questions or Concerns

If you have any questions at all, feel free to reach out to [erhowell@swingleft.org](mailto:erhowell@swingleft.org)

## Running The Code

[If you choose to clone this repo and work from the hello-world sample, please use the directions below. If you implement another solution using a different language or framework, please update these directions to reflect your code.]

## Setup
This project requires python. Everyone has their preferred python setup. If you don't, try [pyenv](https://github.com/pyenv/pyenv). If you're also looking for a way to manage virtual python environments, consider [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv). Regardless, these instructions assume you have a working python environment.

# Set up virtual environment

```bash
cd /where/you/like/source/code
# Check to make sure the version of python is correct.
# The starter code is utilizing Python 3.11 to match the environment we are currently on
python -V

python -m venv <env-name>
cd <env-name>
git clone <github-url>
cd <env-name>

Activate your virtualenv so that pip packages are installed
# locally for this project instead of globally.
source ../bin/activate

pip3 install -r requirements.txt

# Installed kernelspec sl-data-eng-take-home
python -m ipykernel install --user --name=<env-name> --display-name "Python (NYC Collisions)"


```
# Create your postgres DB.

```bash
# Set up the initial state of your DB.
# You can change the name of the db from nyc_collisions to anything you'd like. 
# Just be sure to update the postgres url in the .env 

createdb <nyc_collisions>
```


### Running the server

```bash
# Make sure your environment is running correctly
python main.py

#working with the notebook
jupyter notebook <path_to_notebook>
```