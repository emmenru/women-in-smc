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
andys = 0
mostly_male = 0
mostly_female = 0
authorCount=0
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
andyFile = open('NIMEgenderOutputAndy.csv', 'w')
andyFileWriter = csv.writer(andyFile)
mostly_femaleFile = open('NIMEgenderOutputMostly_female.csv', 'w')
mostly_femalFileWriter = csv.writer(mostly_femaleFile)
mostly_maleFile = open('NIMEgenderOutputMostly_male.csv', 'w')
mostly_maleFileWriter = csv.writer(mostly_maleFile)
uncategorizedFile = open('NIMEgenderOutputUnknown.csv', 'w')
uncategorizedFileWriter = csv.writer(uncategorizedFile)
uncategorizedFileWriter.writerow(['Name', 'Title', 'Year', 'AllAuthors'])


statsFile = open('NIMEstats.csv', 'w')
statsFileWriter = csv.writer(statsFile)



#entries=620
entries=1369 # number of articles
for x in range(1	,entries):
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

		# CHICK IF WEIRD NAMES (TOO SHORT)
		#if len(firstName)<2:
		#	print firstName

		authorGender= detector.get_gender(firstName)
		#print authorGender

		# TRY 2ND GENDER DETECTOR
		#append name that could not be matched to gender to a list
		if (authorGender ==u"unknown"):
			#print "1st gender detector found a name that could not be assigned to gender"
			#print title
			#print firstName
			#print "2nd gender dection generates:"
			authorGenderAlgorithm2=findGender(firstName)
			authorGenderAlgorithm2= ( ", ".join( repr(e) for e in authorGenderAlgorithm2 ) )
			authorGenderAlgorithm2=ast.literal_eval(authorGenderAlgorithm2)
			authorGender=authorGenderAlgorithm2.get("gender")

			# NAMES THAT COULD NOT BE CLASSIFIED
			if not authorGender:
				print "found No match"
				uncategorizedFileWriter.writerow([firstName,title,year,authors])
				authorGender=u"unknown"
				unknowns+=1
				if firstName not in uniqueUnknowns:
					uniqueUnknowns.append(firstName)

		if authorGender==u"andy":
			andys+=1
			andyFileWriter.writerow([firstName,title,str(authors)])
		elif authorGender==u"mostly_female":
			mostly_female+=1
			mostly_femalFileWriter.writerow([firstName,title,str(authors)])
		elif authorGender==u"mostly_male":
			mostly_male+=1
			mostly_maleFileWriter.writerow([firstName,title,str(authors)])
		elif authorGender==u"female":
			female+=1
		elif authorGender==u"male":
			male+=1


		genderDict['name_%02d' % n] = authorGender


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
print "NUMBER OF UNIQUE UNKNOWN: " + str(len(uniqueUnknowns))
print "NUMBER OF ANDYS: " + str(andys)
print "NUMBER OF MOSTLY FEMALE: " + str(mostly_female)
print "NUMBER OF MOSTLY MALE: " + str(mostly_female)
print "NUMBER OF FEMALE: " + str(female)
print "NUMBER OF MALE: " + str(male)


# save stats to CSV
statsFileWriter.writerow(['Conference','TotNames','Unknowns','UniqueUnknowns', 'Andys', 'Mostly Female', 'Mostly Male', 'Female', 'Male'])
statsFileWriter.writerow(['NIME', authorCount,unknowns,len(uniqueUnknowns), andys, mostly_female, mostly_male, female, male])

# Unique Unknowns is not going to be correct, this has to be checked manually, since some of the unknown names have been set to "unknown"
# Have to think about how to do this

### The rest of the names that were outputted in the "unknown" category were googled to identify gender...

# look up these names manually online to see if they are male of female names
# use e.g. http://genderchecker.com/
# https://gender-api.com/ # good
# http://www.genderguesser.com/
# http://www.hipenpal.com/tool/index_in_english.php


#print(bib_database.entries)

