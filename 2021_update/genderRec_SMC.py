# -*- coding: latin-1 -*-
# NOTE THAT THE CSV FILE HAS TO BE SAVED AS UTF8!

import gender
import time
import datetime
import csv
import unicodedata
import ast
import re
import os
from findGender import findGender
from columnNames import newcolumns

# CHANGE HERE FOR DIFFERENT CONFERENCE DATA
confName = 'SMC'
fileName = 'input/SMC_2017-2020_new.csv'

# SAVE CSVs
unknownFile = open(confName+'genderOutputUnknown_2021.csv', 'w')
unknownFileWriter = csv.writer(unknownFile)
ambigiuousFile = open(confName+'genderOutputAmbiguous_2021.csv', 'w')
ambigiuousFileWriter = csv.writer(ambigiuousFile)
statsFile = open(confName+'stats_2021.csv', 'w')
statsFileWriter = csv.writer(statsFile)
outputFile = open(confName+'genderOutput_2021.csv', 'w') 
outputWriter = csv.writer(outputFile)
outputWriter.writerow(newcolumns)

# STATS
unknowns=0
ambiguous = 0
totNames = 0
uniqueUnknowns = list()
male=0
female=0

authorlist=list()
yearlist=list()

nameDict = {}
genderDict = {}
probabilityDict = {}

def cleanName(authorString):
    # remove blank spaces in the beginning of the author name
    startString = authorString
    authorString = authorString.split()[0]
    authorString = re.compile('^\xa0').sub('',authorString)
    authorString = re.compile('^\xc2').sub('',authorString)
    authorString = authorString.lstrip()
    #Dr. is not a name 
    #S. M. is not a name 
    # if there is a '.' in the string:
    # this is not working 
    if '.' in authorString and len(authorString.split(' ')[0]) <= 2 :
        print('******FOUND AN INITIAL!!!!******')
        # remove the characters around the '.' (e.g. initials)
        authorString = startString
    authorString = (max(list(authorString.split(' ')), key=len))
    return(authorString)

def writeOutput(authors, nameDict, genderDict, probabilityDict, country, year, numAuthors, title):
    outputWriter.writerow(
                [str(authors), 
                nameDict.get("name_00", None), 
                genderDict.get("name_00", None), 
                country, 
                year, 
                numAuthors, 
                title, 
                'ICMC',
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
                ]) 

# write stats file
statsFileWriter.writerow(['Conference','TotNames','Unknowns','UniqueUnknowns', 'Ambiguous', 'Female', 'Male'])


with open(fileName, newline='') as csvfile:
    rows = csv.reader(csvfile, delimiter=';')
    counter = 0
    for i in rows:
        # for debugging and setting a subset 
        counter = counter +1 
        #print(counter)
        #print(i)
        if counter>1: # skip the first row since that is just the column name
            if counter==20: # for debugging
                break 
            #titlelist.append(i[0])
            title = i[0]
            year  = i[2]
            country = i[3]
            print(year)
            #yearlist.append(i[2])
            #print(authorlist[1]) # first author name (0 corresponds to column)
            authors = (str(i[1]))
            print('1: ', authors)
            authors = authors.split(',')
            authorlist.append(authors)
            print(authors)
            numAuthors=len(authors) 
            for a in range(0,numAuthors): # corresponds to the authors in respective row
                totNames+=1
                author=authors[a]
                author=str(author)
                #print(author)
                author = cleanName(author)
                nameDict['name_%02d' % a] = author

                # CLASSIFICATION
                authorGenderAlgorithm2=findGender(author)
                authorGenderAlgorithm2= ( ", ".join( repr(e) for e in authorGenderAlgorithm2 ) )         
                authorGenderAlgorithm2=ast.literal_eval(authorGenderAlgorithm2)
                #print(authorGenderAlgorithm2)
                authorGender=str(authorGenderAlgorithm2.get("gender"))
                probability=str(authorGenderAlgorithm2.get("probability"))

                # bugs in output
                if authorGender ==str(None): # if "None" from algorithm two
                    unknowns+=1
                    unknownFileWriter.writerow([str(author),str(title),str(authors),str(year)])
                    if author not in uniqueUnknowns:
                        uniqueUnknowns.append(author)
                elif authorGender==u"female":
                    female+=1
                    if float(probability)<0.8:
                        print('****Ambiguous author**** '+str(author))
                        ambiguous+=1
                        ambigiuousFileWriter.writerow([str(author),str(authorGender),str(probability),str(title),str(authors), str(year)])
                elif authorGender==u"male":
                    male+=1
                    if float(probability)<0.8:
                        print('****Ambiguous author**** '+str(author))
                        ambiguous+=1
                        ambigiuousFileWriter.writerow([str(author),str(authorGender),str(probability),str(title),str(authors), str(year)])


                genderDict['name_%02d' % a] = authorGender

                probabilityDict['probability_%02d' % a] = probability

            #print('I AM WRITING A ROW')
            # write output file 
            writeOutput(authors, nameDict, genderDict, probabilityDict, country, year, numAuthors, title)
            # need to empty nameDict, probabilityDict, genderDict for each row 
            nameDict = {}
            genderDict = {}
            probabilityDict = {}


    # this should be done for each year? or do this in separate script?
    # totNames, unknowns, uniqueunknowns, female, male, ambiguous should be resetted every year  
    statsFileWriter.writerow([confName, totNames,unknowns, len(uniqueUnknowns), ambiguous, female, male])

print("TOTAL NUMBER OF NAMES: " + str(totNames))
print("NUMBER OF UNKNOWNS: " + str(unknowns))
print("NUMBER OF UNIQUE UNKNOWNS: " + str(len(uniqueUnknowns)))
print("NUMBER OF PROBS < 0.8 : " + str(ambiguous))
print("NUMBER OF FEMALE: " +str(female))
print("NUMBER OF MALE: " +str(male))
