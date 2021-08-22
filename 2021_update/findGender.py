
from genderize import Genderize


def findGender(name):
    print (name)
    outputList=(Genderize(timeout=50.0).get([name]))
    # if subscribing change api key here 
    #outputList=(Genderize(api_key='7fa4375c6244afadf9ee90e06e4cd996', timeout=50.0).get([name]))
    return outputList