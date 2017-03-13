# -*- coding: UTF-8 -*-
#!/usr/bin/python
import sqlite3
import time
import datetime
import random
import re
import csv
import unicodedata
import ast
import bibtexparser
from collections import namedtuple
from tex_converter import convert_tex_string

# CHECK IF NAMES IN THE UNKNOWN LIST COMES FROM UNKNOWN UNICODE CHARACTERS

# not sure if this is fixed yet
# names that are written to the "unknown" file do not have all author names
# also, the year column is wrong, it writes first name

### CHANGE THIS SO THAT SECOND GENDER DETECTOR ALGORITHM IS USED

# THE FIRST GENDER DETECTOR LIBRARY IS gender_guesser.detector
import gender_guesser.detector as gender
# This package uses the underlying data from the program “gender” by Jorg Michael
# https://autohotkey.com/board/topic/20260-gender-verification-by-forename-cmd-line-tool-db/
detector = gender.Detector(case_sensitive=False)
# output: "male", "female", "mostly male", "mostly female", "andy" for andrygonous (50 % 50 %, whereas unknown is not found in the database)

# THE SECOND GENDER DETECTOR LIBRARY IS genderize
from findGender import findGender
# imported from the function findGender.py
# Client for Genderize.io web service. https://bat-country.us/#genderize
# output: "male", "female", also probabilities

# THE 3RD GENDER DETECTOR
# NOT USED YET
# Gender detector is a Python library for guessing a person’s gender by his/her first name.
# This library is based on [beauvoir](https://github.com/jeremybmerrill/beauvoir) with support for
# United States, United Kingdom, Argentina and Uruguay.
#from gender_detector import GenderDetector
# instantiate gender detector
# output : "male", "female"
#myDetectorUS= GenderDetector('us')
#myDetectorUK= GenderDetector('uk')
#myDetectorARG= GenderDetector('ar') # argentina



## STATS
unknowns=0
ambiguous = 0
authorCount = 0
uniqueUnknowns = list()
male=0
female=0

# BIBTEX PARSER
with open('nimeMERGED.bib') as bibtex_file:
    bibtex_str = bibtex_file.read()
bib_database = bibtexparser.loads(bibtex_str)

print('****NIME****')
outputFile = open('genderOutputNEW.csv', 'w')
outputWriter = csv.writer(outputFile)
outputWriter.writerow(['AllAuthors', 'FirstName1stAuthor', 'Gender', 'FirstAuthorCountry', 'Year', 'NumberOfAuthors', 'Title', 'Conference', 'FirstName2ndAuthor', 'Gender2', 'FirstName3rdAuthor', 'Gender3','FirstName4thAuthor','Gender4','FirstName5thAuthor', 'Gender5', 'FirstName6thAuthor','Gender6','FirstName7thAuthor','Gender7','FirstName8thAuthor','Gender8','FirstName9thAuthor','Gender9','FirstName10thAuthor','Gender10'])



### SAVE CSVs
uncategorizedFile = open('NIMEgenderOutputUnknown.csv', 'w')
uncategorizedFileWriter = csv.writer(uncategorizedFile)
uncategorizedFileWriter.writerow(['Name', 'Title', 'Names'])
ambigiuousFile = open('NIMEgenderOutputAmbiguous.csv', 'w')
ambigiuousFileWriter = csv.writer(ambigiuousFile)
statsFile = open('NIMEstats.csv', 'w')
statsFileWriter = csv.writer(statsFile)


#entries=620
entries=1369 # number of articles
for x in range(0,entries):
    print "Article: %s" % x
    secondName=''
    secondAuthorGender=''
    entry=bib_database.entries[x]
    authors =(entry['author'])
    year =(entry['year'])
    title =(entry['title'])
    country =(entry['address'])


    maxNumberOfauthors=10 # specifically for NIME
    authors= re.split(r" and ", authors)

    numberOfAuthors= len(authors)

    nameDict = {}
    genderDict = {}

    for n in range(0, numberOfAuthors):
        authorCount=authorCount+1
        # TRY 1ST GENDER DETECTOR
        mainAuthorLine =str(authors[n])
        firstName = mainAuthorLine[mainAuthorLine.find(',')+1 :  ]
        firstName = firstName.split()[0]
        firstNameRaw = firstName
        firstName = convert_tex_string(firstName)
        nameDict['name_%02d' % n] = firstName

        # CHECK IF WEIRD NAMES (TOO SHORT)
        #if len(firstName)<2:
        #   print firstName

        authorGenderAlgorithm2=findGender(firstName)
        authorGenderAlgorithm2= ( ", ".join( repr(e) for e in authorGenderAlgorithm2 ) )
        authorGenderAlgorithm2=ast.literal_eval(authorGenderAlgorithm2)
        #print authorGenderAlgorithm2
        authorGender=str(authorGenderAlgorithm2.get("gender"))
        probability=str(authorGenderAlgorithm2.get("probability"))
        #print probability

        if authorGender ==str(None): # if "None" from algorithm two
            unknowns+=1
            uncategorizedFileWriter.writerow([str(firstName),str(title),str(authors)])
            if firstName not in uniqueUnknowns:
                uniqueUnknowns.append(firstName)
        elif authorGender==u"female":
            female+=1
            if float(probability)<0.8:
                #print "ambiguous ambiguous ambiguous ambiguous :"+str(firstName)
                ambiguous+=1
                ambigiuousFileWriter.writerow([str(firstName),str(authorGender),str(probability),str(title),str(authors)])
        elif authorGender==u"male":
            male+=1
            if float(probability)<0.8:
                #print "ambiguous ambiguous ambiguous ambiguous :"+str(firstName)
                ambiguous+=1
                ambigiuousFileWriter.writerow([str(firstName),str(authorGender),str(probability),str(title),str(authors)])

        #print authorGender
        genderDict['name_%02d' % n] = authorGender
        #print genderDict


    outputWriter.writerow(
        [unicode(authors),
        nameDict.get("name_00", None),
        genderDict.get("name_00", None),
        country,
        year,
        numberOfAuthors,
        title,
        'NIME',
        nameDict.get("name_01", None),
        genderDict.get("name_01", None),
        nameDict.get("name_02", None),
        genderDict.get("name_02", None),
        nameDict.get("name_03", None),
        genderDict.get("name_03", None),
        nameDict.get("name_04", None),
        genderDict.get("name_04", None),
        nameDict.get("name_05", None),
        genderDict.get("name_05", None),
        nameDict.get("name_06", None),
        genderDict.get("name_06", None),
        nameDict.get("name_07", None),
        genderDict.get("name_07", None),
        nameDict.get("name_08", None),
        genderDict.get("name_08", None),
        nameDict.get("name_09", None),
        genderDict.get("name_09", None),
        nameDict.get("name_10", None),
        genderDict.get("name_10", None)
        ]
    )

print('****FINISHED WITH NIME****')

outputFile.close()


print "TOTAL NUMBER OF NAMES: " + str(authorCount)
print "NUMBER OF UNKNOWNS: " + str(unknowns)
print "NUMBER OF UNIQUE UNKNOWNS: " + str(len(uniqueUnknowns))
print "NUMBER OF PROBS < 0.8 : " + str(ambiguous)
print "NUMBER OF FEMALE: " +str(female)
print "NUMBER OF MALE: " +str(male)

# save stats to CSV
statsFileWriter.writerow(['Conference','TotNames','Unknowns','UniqueUnknowns', 'Ambiguous', 'Female', 'Male'])
statsFileWriter.writerow(['NIME', authorCount,unknowns,len(uniqueUnknowns), ambiguous, female, male])


# Unique Unknowns is not going to be correct, this has to be checked manually, since some of the unknown names have been set to "unknown"
# Have to think about how to do this

### The rest of the names that were outputted in the "unknown" category were googled to identify gender...

# look up these names manually online to see if they are male of female names
# use e.g. http://genderchecker.com/
# https://gender-api.com/ # good
# http://www.genderguesser.com/
# http://www.hipenpal.com/tool/index_in_english.php


#print(bib_database.entries)

