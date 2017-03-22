# -*- coding: latin-1 -*-
# NOTE THAT THE CSV FILE HAS TO BE SAVED AS UTF8!
# IMPORT XLS FILE TO GOOGLE DOCS AND SAVE AS CSV THERE

# SMC GENDER RECOGNITION

import pandas as pd
import time
import datetime
import csv
import unicodedata
import ast
import re
import os


### NOT SAVING ALL AUTHORS : MAX NUM AUTHORS SHOULD BE 14, not 10
### FIX THIS IN: newcolumns=[] and if m == 0: # first author nameColumnToWrite=1 genderColumnToWrite=2

# THE FIRST GENDER DETECTOR LIBRARY IS gender_guesser.detector
import gender_guesser.detector as gender
detector = gender.Detector(case_sensitive=False)

# THE SECOND GENDER DETECTOR LIBRARY IS genderize
from findGender import findGender

df=pd.read_csv('SMC2.csv', sep=',')
df[['Title', 'Author(s)', 'Country']] = df[['Title', 'Author(s)', 'Country']].astype('str')
df[['Year']] = df[['Year']].astype(int)


newcolumns=['AllAuthors',
'FirstName1stAuthor',
'Gender',
'Place',
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
'Gender17']

newDF = pd.DataFrame(columns=newcolumns)
newDF[['AllAuthors']]=df[['Author(s)']]
newDF[['Year']]=df[['Year']]
newDF[['Title']]=df[['Title']]
newDF[['Conference']]='SMC'
newDF[['Place']]=df[['Country']]


### SAVE CSVs
unknownFile = open('SMCgenderOutputUnknown.csv', 'w')
unknownFileWriter = csv.writer(unknownFile)
andyFile = open('SMCgenderOutputAndy.csv', 'w')
andyFileWriter = csv.writer(andyFile)
mostly_femaleFile = open('SMCgenderOutputMostly_female.csv', 'w')
mostly_femalFileWriter = csv.writer(mostly_femaleFile)
mostly_maleFile = open('SMCgenderOutputMostly_male.csv', 'w')
mostly_maleFileWriter = csv.writer(mostly_maleFile)

statsFile = open('SMCstats.csv', 'w')
statsFileWriter = csv.writer(statsFile)

## STATS
unknowns=0
andys = 0
mostly_male = 0
mostly_female = 0
totNames = 0
uniqueUnknowns = list()
male=0
female=0

        # NOTE: Some names have not been found, these have been labeled "Unknown in the CSV file"

# for rows in data frame
for i in range(0, len(df)):
    authorlist=df.ix[i,1]
    title=df.ix[i,0]
    authors = authorlist.split(";")
    numAuthors=0
    # for authors in authorlist for every row
    for m in range(0, len(authors)):
        totNames+=1
        numAuthors+=1
        author=authors[m]
        author=str(author)

        #print author # some of the lines are not correctly formatted (some have the syntax "Frid, Emma", whereas other have "Emma Frid")
        # if formatted with comma
        if ',' in author:
            author = author.split(",")[1]
            if ' ' in author:
                # remove blank spaces in the beginning of the author name
                author = re.compile('^\xa0').sub('',author)
                author = re.compile('^\xc2').sub('',author)
                author = author.lstrip()
                author = author.split(" ")[0]
        # if not formatted with comma
        else:
            # remove blank spaces in the beginning of the author name
            author = author.lstrip()
            author = author.split(" ")[0]
            author = author.replace('\xa0', '')
            author = author.replace('\xc2', '')
        # now we have all the names and need to iterate over all m in len(authors) to get gender classification
        # 1ST CLASSIFICATION METHOD
        # CHICK IF WEIRD NAMES (TOO SHORT)
        #if len(author)<4:
        #  print author

        authorGender= str(detector.get_gender(author))


        # unknowns until here get "unknown"
        # 2ND CLASSIFICATION METHOD
        if (authorGender ==u"unknown"):
            authorGenderAlgorithm2=findGender(author)
            authorGenderAlgorithm2= ( ", ".join( repr(e) for e in authorGenderAlgorithm2 ) )
            authorGenderAlgorithm2=ast.literal_eval(authorGenderAlgorithm2)
            authorGender=authorGenderAlgorithm2.get("gender")

        # assign gender to column
        # define which column to write to depending on which author (1st, 2nd etc.) it is

        genderColumnToWrite=int()
        nameColumnToWrite=int()
        if m == 0: # first author
            nameColumnToWrite=1
            genderColumnToWrite=2
        elif m == 1: # second author
            nameColumnToWrite=8
            genderColumnToWrite=9
        elif m == 2: # third author
            nameColumnToWrite=10
            genderColumnToWrite=11
        elif m == 3: # fourth author
            nameColumnToWrite=12
            genderColumnToWrite=13
        elif m == 4: # fifth author
            nameColumnToWrite=14
            genderColumnToWrite=15
        elif m == 5: # sixth author
            nameColumnToWrite=16
            genderColumnToWrite=17
        elif m == 6: # seventh author
            nameColumnToWrite=18
            genderColumnToWrite=19
        elif m == 7: # eight author
            nameColumnToWrite=20
            genderColumnToWrite=21
        elif m == 8: # ninth author
            nameColumnToWrite=22
            genderColumnToWrite=23
        elif m == 9: # tenth author
            nameColumnToWrite=24
            genderColumnToWrite=25
        elif m == 10: # 11th author
            #print m
            nameColumnToWrite=26
            genderColumnToWrite=27
        elif m == 11: # 12th author
            nameColumnToWrite=28
            genderColumnToWrite=29
        elif m == 12: # 13th author
            nameColumnToWrite=30
            genderColumnToWrite=31
        elif m == 13: # 14th author
            nameColumnToWrite=32
            genderColumnToWrite=33
        elif m == 14: # 15th author
            nameColumnToWrite=34
            genderColumnToWrite=35
        elif m == 15: # 16th author
            nameColumnToWrite=36
            genderColumnToWrite=37
        elif m == 16: # 17th author
            nameColumnToWrite=38
            genderColumnToWrite=39

        # NAMES THAT COULD NOT BE CLASSIFIED
        if not authorGender: # if "None" from algorithm two
            unknowns+=1
            print author
            # unknowns after here get "None"
            # maybe better if they are labelled as "unknown"

            authorGender=u"unknown"
            unknownFileWriter.writerow([author,title,str(authors)])
            if author not in uniqueUnknowns:
                uniqueUnknowns.append(author)
        elif authorGender==u"andy":
            andys+=1
            andyFileWriter.writerow([author,title,str(authors)])
        elif authorGender==u"mostly_female":
            mostly_female+=1
            mostly_femalFileWriter.writerow([author,title,str(authors)])
        elif authorGender==u"mostly_male":
            mostly_male+=1
            mostly_maleFileWriter.writerow([author,title,str(authors)])
        elif authorGender==u"female":
            female+=1
        elif authorGender==u"male":
            male+=1

        newDF.ix[i,nameColumnToWrite]=author # first author name
        newDF.ix[i,genderColumnToWrite]=authorGender # first author gender
        #print genderColumnToWrite
        #print str(author) + ' - ' + str(authorGender)

# set num authors per publication
    newDF.ix[i,5]=numAuthors
    #print newDF.ix[i,]

print "TOTAL NUMBER OF NAMES: " + str(totNames)
print "NUMBER OF UNKNOWNS: " + str(unknowns)
print "NUMBER OF UNIQUE UNKNOWNS: " + str(len(uniqueUnknowns))
print "NUMBER OF ANDYS: " + str(andys)
print "NUMBER OF MOSTLY FEMALE: " + str(mostly_female)
print "NUMBER OF MOSTLY MALE: " + str(mostly_male)
print "NUMBER OF FEMALE: " +str(female)
print "NUMBER OF MALE: " +str(male)

# save stats to CSV
statsFileWriter.writerow(['Conference','TotNames','Unknowns','UniqueUnknowns', 'Andys', 'Mostly Female', 'Mostly Male', 'Female', 'Male'])
statsFileWriter.writerow(['SMC', totNames,unknowns,len(uniqueUnknowns), andys, mostly_female, mostly_male, female, male])

# save file to CSV
newDF.to_csv('SMCgenderOutput.csv', sep=',')


