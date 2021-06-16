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

# genderize
from findGender import findGender
# imported from the function findGender.py
# Client for Genderize.io web service. https://bat-country.us/#genderize
# output: "male", "female", also probabilities

## STATS
unknowns=0
ambiguous = 0
authorCount = 0
uniqueUnknowns = list()
male=0
female=0

# BIBTEX PARSER
with open('input/NIME_2017-2020.bib') as bibtex_file:
    bibtex_str = bibtex_file.read()
    #print(bibtex_str)
bib_database = bibtexparser.loads(bibtex_str)

print('****NIME****')
outputFile = open('NIMEgenderOutput_2021.csv', 'w')
outputWriter = csv.writer(outputFile)
outputWriter.writerow(['AllAuthors',
    'FirstName1stAuthor',
    'Gender',
    'FirstAuthorCountry',
    'Year',
    'NumberOfAuthors',
    'Title',
    'Conference',
    'FirstName2ndAuthor',
    'Gender2',
    'FirstName3rdAuthor',
    'Gender3',
    'FirstName4thAuthor',
    'Gender4',
    'FirstName5thAuthor',
    'Gender5',
    'FirstName6thAuthor',
    'Gender6',
    'FirstName7thAuthor',
    'Gender7',
    'FirstName8thAuthor',
    'Gender8',
    'FirstName9thAuthor',
    'Gender9',
    'FirstName10thAuthor',
    'Gender10',
    'FirstName11thAuthor',
    'Gender11',
    'FirstName12thAuthor',
    'Gender12',
    'FirstName13thAuthor',
    'Gender13',
    'FirstName14thAuthor',
    'Gender14',
    'FirstName15thAuthor',
    'Gender15',
    'FirstName16thAuthor',
    'Gender16',
    'FirstName17thAuthor',
    'Gender17',
    'Probability1',
    'Probability2',
    'Probability3',
    'Probability4',
    'Probability5',
    'Probability6',
    'Probability7',
    'Probability8',
    'Probability9',
    'Probability10',
    'Probability11',
    'Probability12',
    'Probability13',
    'Probability14',
    'Probability15',
    'Probability16',
    'Probability17'
    ])



### SAVE CSVs
uncategorizedFile = open('NIMEgenderOutputUnknown_2021.csv', 'w')
uncategorizedFileWriter = csv.writer(uncategorizedFile)
uncategorizedFileWriter.writerow(['Name', 'Title', 'Names'])
ambigiuousFile = open('NIMEgenderOutputAmbiguous_2021.csv', 'w')
ambigiuousFileWriter = csv.writer(ambigiuousFile)
statsFile = open('NIMEstats_2021.csv', 'w')
statsFileWriter = csv.writer(statsFile)


entries = len(bib_database.entries) # number of articles 
for x in range(0,entries): 
    print ("Article: %s" % x)
    secondName=''
    secondAuthorGender=''
    entry=bib_database.entries[x]
    authors =(entry['author'])
    year =(entry['year'])
    title =(entry['title'])
    country =(entry['address'])

    #print year
    #maxNumberOfauthors=10 # specifically for NIME
    authors= re.split(r" and ", authors)

    numberOfAuthors= len(authors)

    nameDict = {}
    genderDict = {}
    probabilityDict = {}

    for n in range(0, numberOfAuthors):
        authorCount=authorCount+1
        # TRY 1ST GENDER DETECTOR
        mainAuthorLine =str(authors[n])
        firstName = mainAuthorLine[mainAuthorLine.find(',')+1 :  ]
        firstName = firstName.split()[0]
        firstNameRaw = firstName
        firstName = convert_tex_string(firstName)
        nameDict['name_%02d' % n] = firstName.decode('UTF-8')

        # CHECK IF WEIRD NAMES (TOO SHORT)
        #if len(firstName)<2:
        #   print firstName

        authorGenderAlgorithm2=findGender(firstName.decode('UTF-8'))
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

        probabilityDict['probability_%02d' % n] = probability
        #print probabilityDict


    outputWriter.writerow(
        [str(authors),
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
        genderDict.get("name_10", None),
        nameDict.get("name_11", None),
        genderDict.get("name_11", None),
        nameDict.get("name_12", None),
        genderDict.get("name_12", None),
        nameDict.get("name_13", None),
        genderDict.get("name_13", None),
        nameDict.get("name_14", None),
        genderDict.get("name_14", None),
        nameDict.get("name_15", None),
        genderDict.get("name_15", None),
        nameDict.get("name_16", None),
        genderDict.get("name_16", None),
        probabilityDict.get("probability_00", None),
        probabilityDict.get("probability_01", None),
        probabilityDict.get("probability_02", None),
        probabilityDict.get("probability_03", None),
        probabilityDict.get("probability_04", None),
        probabilityDict.get("probability_05", None),
        probabilityDict.get("probability_06", None),
        probabilityDict.get("probability_07", None),
        probabilityDict.get("probability_08", None),
        probabilityDict.get("probability_09", None),
        probabilityDict.get("probability_10", None),
        probabilityDict.get("probability_11", None),
        probabilityDict.get("probability_12", None),
        probabilityDict.get("probability_13", None),
        probabilityDict.get("probability_14", None),
        probabilityDict.get("probability_15", None),
        probabilityDict.get("probability_16", None),
        probabilityDict.get("probability_17", None)
        ]
    )

print('****FINISHED WITH NIME****')

outputFile.close()


print ("TOTAL NUMBER OF NAMES: " + str(authorCount))
print ("NUMBER OF UNKNOWNS: " + str(unknowns))
print ("NUMBER OF UNIQUE UNKNOWNS: " + str(len(uniqueUnknowns)))
print ("NUMBER OF PROBS < 0.8 : " + str(ambiguous))
print ("NUMBER OF FEMALE: " +str(female))
print ("NUMBER OF MALE: " +str(male)) 

# save stats to CSV
statsFileWriter.writerow(['Conference','TotNames','Unknowns','UniqueUnknowns', 'Ambiguous', 'Female', 'Male'])
statsFileWriter.writerow(['NIME', authorCount,unknowns,len(uniqueUnknowns), ambiguous, female, male])


# Unique Unknowns is not going to be correct, this has to be checked manually, since some of the unknown names have been set to "unknown"

#print(bib_database.entries)

