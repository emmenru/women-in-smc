# -*- coding: latin-1 -*-

import csv
import numpy

# for ICMA Array 
# this has to be done since the stats reported in my ICMC paper from 2017 did not 
# take into account that some authors were presented several times 
# in other words, it did not look on UNIQUE AUTHOR stats 
# this scripts takes in the predicted data (after going through unknown authors manually) 
# and outputs a corrected statistics file

# virtual env: /Users/emmafrid/Dev/VirtualEnvs/women-in-smc

# input: 
# ICMCgenderOutput_2021_for_R.csv (years after 2016)
# ICMC.csv (years before 2016, downloaded from supplementary material from ICMC paper)
# ICMC_stats_new.csv (contains all years, but 2019-2020 was one conference since the 19 edition was cancelled)
# two conference years are therefore missing in the analysis, 2020 and 2021

# the two files have different formats
proceedingsData = "input/ICMC_reformatted.csv"
#proceedingsData = "input/ICMCgenderOutput_2021_for_R.csv"
statsData = "input/ICMC_stats_new.csv"

years = list(range(1975,2017)) # wait, where there not some years that it did not happen?
nameColumns = list(range(8,40,2))
nameColumns.insert(0,1) # there are 17 columns with first names, and corresponding genders 
#print(nameColumns) 
genderColumns = numpy.array(nameColumns)
genderColumns = (genderColumns + 1)

def collectFirstnames(row):
    # collects all first names for a row
    year = row[4]
    
    [firstName, lastName, genderColumn] = findFirstOrLastName(row)
    


def findFirstOrLastName(row): 
    persons = row[0]
    # if there is a comma in the string, first name is the name after the comma 
    persons = (persons.split(";"))
    #print(persons)
    counter = 0
    personDict = dict()

    for person in persons: # note that person is a list 
        personDict = {"Name":[],"Last name":[],"Year":[], "Gender":[]};
        genderCol = genderColumns[counter] 
        #print(counter, person)
        counter += 1
        #print(person)
        # if name formatted with comma : 
        if "," in person: 
            #print("formatted with comma")
            names = (person.split(",")) 
            first = names[1]
            last = names[0]
        else: 
            #print("not formatted with comma")
            (first, last) = person.split(maxsplit=1)
        # remove empty space in beginning of name 
        first= first.strip()
        last= last.strip()
        #print("gender column: ", genderCol)
        gender = row[genderCol]
        #print("gender : ", gender)
        personDict["Name"].append(first)
        personDict["Last name"].append(last)
        personDict["Year"].append(year)
        personDict["Gender"].append(gender)
        print(personDict)
    return(first, last, genderCol)


with open(proceedingsData, newline='') as csvfile:
    rows = csv.reader(csvfile, delimiter=';')
    years_printed = []
    firstNames = [] 
    firstNames_per_year = []

    # this is the list that we use to check if there are identical names  
    # identified by checking if first names are the same, if last names are the same, if year is the same

    for row in rows:
        authors = row[0]
        year = row[4]

        if year == "1975":
            #print(authors)
            collectFirstnames(row)
            #print(names)
            # unlist strings and sort them to see if there are any identical names 
            # identify if some of the firstNames are identical by sorting them



        #if year not in years_printed:
        #    years_printed.append(year)
        #    print(year)

    #print(sorted(firstNames))
    # analysis has to be done on a year basis     

# to do - is there something funky where there is an ICMC 
# ICMC_stats_new.csv needs to be rerun since there was an error in the csv file (yinrui) used to generate that 

# output:  
# ICMCstats_2021_unique_authors.csv

