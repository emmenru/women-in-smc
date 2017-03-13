
from genderize import Genderize

def findGender(name):
    print name
    outputList=(Genderize().get([name]))
    return outputList