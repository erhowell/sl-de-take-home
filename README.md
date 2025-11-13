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
2. Loads the raw data into a local Postgres database 
3. Transforms it into clean analytical tables
4. Directly query collision_summary from a Jupyter notebook



## What we are looking for

- Does it work? _*Note that you can "mock" an aspect of your solution rather than fully implement it, for example if a feature you want to demonstrate requires additional data. Just be clear in your submission notes what was mocked.*_
- Is the code clean and accessible to others?
- Does the code handle edge case conditions?


## Time Limit

The purpose of the test is not to measure the speed of code creation. Please try to finish within 5 days of being sent the code test, but extra allowances are fine and will not be strictly penalized.

## Submitting Your Code

The preferred way to submit your code is to create a fork of this repo, push your changes to the forked repo, and then either:
- open a pull request against the original repo from your forked repo
- grant access to your forked repo to erhowell, so that we can access the code there.
Alternatively, you may submit the code in the form of a zip file and send it to erhowell@swingleft.org. If you do this, please be sure to include a README in your submission with full details on how to set up and run your code.

## Questions or Concerns

If you have any questions at all, feel free to reach out to [erhowell@swingleft.org](mailto:erhowell@swingleft.org)

## Running The Code

[If you choose to clone this repo and work from the hello-world sample, please use the directions below. If you implement another solution using a different language or framework, please update these directions to reflect your code.]

## Setup
This project requires python. Everyone has their preferred python setup. If you don't, try [pyenv](https://github.com/pyenv/pyenv). If you're also looking for a way to manage virtual python environments, consider [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv). Regardless, these instructions assume you have a working python environment.

# Set up virtual environment

```bash
cd /where/you/like/source/code
# See: https://docs.python.org/3/library/venv.html
python -m venv <directory-name>
cd <directory-name>
git clone <github-url>
cd <directory-name>

Activate your virtualenv so that pip packages are installed
# locally for this project instead of globally.
source ../bin/activate
export PYTHONPATH=.

pip3 install -r requirements.txt

# Installed kernelspec sl-data-eng-take-home
python -m ipykernel install --user --name=sl-data-eng-take-home --display-name "Python (NYC Collisions)"


```
# Create your postgres DB.

```bash
# Set up the initial state of your DB.
# You can change the name of the db from nyc_collisions to anything you'd like. Just be sure to update the postgres url in the .env 

createdb nyc_collisions
```


### Running the server

```bash
# Make sure your environment is running correctly
python main.py

#working with the notebook
jupyter notebook analyze_collisions.ipynb
```