# -*- coding: latin-1 -*-

import csv
import numpy
from operator import itemgetter

# for ICMA Array 
# this has to be done since the stats reported in my ICMC paper from 2017 did not 
# take into account that some authors published several papers in the same year
# this scripts inputs the predicted data (after going through unknown authors manually) and outputs new stats for only unque authors 

# virtual env: /Users/emmafrid/Dev/VirtualEnvs/women-in-smc

# input: 
# ICMC_reformatted_all_years.csv (years before 2016, downloaded from supplementary material from ICMC paper, fixed one for 1975 where no gender was recorded)
# ICMCgenderOutput_1975-2021_for_R.csv (years after 2016) # different format, perhaps code must be different 

# ICMC_stats_new.csv (contains all years apart from 2020, which was published together with 2021 due to covid)

# TO DO: 
# Check that the script works also for data after 2016 
# Check that stats calc in R is correct 
# Make sure that the data is modified so that ICMCgenderOutput_1975-2021_for_R also works....

# the two files have different formats
proceedingsData = "input/ICMC_reformatted_all_years.csv"
# THIS IS NOT WORKING YET - probably since the format is different for the names?
#proceedingsData = "input/ICMCgenderOutput_1975-2021_for_R_before_manual_fix.csv"
# check last row, where there is an additional row name 
statsData = "input/ICMC_stats_new.csv"

years = list(range(1975,2020)) 
nameColumns = list(range(8,40,2))
nameColumns.insert(0,1) # there are 17 columns with first names, and corresponding genders 
genderColumns = numpy.array(nameColumns)
genderColumns = (genderColumns + 1)

# output 
outputFile = open("output/ICMC_stats_unique_authors.csv", "w") 
outputWriter = csv.writer(outputFile)

def createPersonDict(personDict, first, last, year, gender, title):
        personDict["Name"].append(first)
        personDict["Last name"].append(last)
        personDict["Year"].append(year)
        personDict["Gender"].append(gender)
        personDict["Title"].append(title)
        return(personDict)

def getData(row): 
    counter = 0
    year = row[4]
    persons = row[0]
    # if there is a comma in the string, first name is the name after the comma 
    persons = (persons.split(";"))
    personDict = dict()
    personListPerRow = list()
    for person in persons: # note that person is a list 
        personDict = {"Name":[],"Last name":[],"Year":[], "Gender":[], "Title":[]};
        genderCol = genderColumns[counter] 
        counter += 1
        # if name formatted with comma : 
        if "," in person: 
            names = (person.split(",")) 
            first = names[1]
            last = names[0]
        else: 
            (first, last) = person.split(maxsplit=1)
        # remove empty space in beginning of name 
        first= first.strip()
        last= last.strip()
        gender = row[genderCol]
        title=row[6]
        personDict = createPersonDict(personDict,first,last,year,gender, title)
        #print(counter)
        personListPerRow.append(personDict)
        # list of dictionaries
    return(personListPerRow) 

def getNamesFromCSV(year_to_check):
    with open(proceedingsData, newline='') as csvfile:
        rows = csv.reader(csvfile, delimiter=';')
        allPersons = []
        for row in rows:
            authors = row[0]
            year = row[4]
            if year == year_to_check:
                personsPerRow = getData(row)
                allPersons = allPersons+personsPerRow
    return(allPersons)

def calcCompensation(gender):
    [maleCountCompensation, femaleCountCompensation, noneCountCompensation, totalCountCompensation] = [0,0,0,0]
    gender = gender.strip("[]").strip("''")
    totalCountCompensation -= 1
    if gender == "male":
        maleCountCompensation -= 1
    elif gender == "female":
        femaleCountCompensation -= 1
    elif gender == "None":
        noneCountCompensation -= 1
    else: 
        raise TypeError("Could not find gender for identical author name.") 
    return(numpy.array([maleCountCompensation, femaleCountCompensation, noneCountCompensation, totalCountCompensation]))

def findDuplicates(allPersonsOneYear):
    # sort by name AND lastname 
    newlist = sorted(allPersonsOneYear, key=itemgetter("Name", "Last name"))
    # for debugging, print entire newlist to see that the last entries are correct
    #print(newlist)
    compensationArray = numpy.array([0,0,0,0])
    for i in range(len(newlist)-1):
        old_person = newlist[i]
        new_person = newlist[i+1]
        name_row_1 = str(old_person.get("Name"))#.lower()
        name_row_2 = str(new_person.get("Name"))#.lower()
        lastname_row_1 = str(old_person.get("Last name"))#.lower()
        lastname_row_2 = str(new_person.get("Last name"))#.lower()
        title = new_person.get("Title")
        print(i, name_row_1, lastname_row_1, name_row_2, lastname_row_2)
        # identify items with identical first and last names 
        if (name_row_2 == name_row_1 and lastname_row_1 == lastname_row_2):
            print("IDENTICAL NAME IDENTIFIED")
            # no compensation if name_row_1 is "Unknown"
            if (name_row_1=="Unknown"): 
                pass 
            else: 
                gender = str(newlist[i].get("Gender")) # not sure if this is correct i 
                print("new compensation: ", calcCompensation(gender)) 
                compensationArray =  numpy.add(compensationArray,calcCompensation(gender))
            print("total compensation: ", compensationArray) 
    # assert that the sum of the first three elements is equal to the last one
    assert(compensationArray[0:3].sum() == compensationArray[3])
    return(compensationArray)

def fixStatsFile(statsdata, year_to_check, compensationArray):
    with open(statsdata, newline='') as csvfile:
        rows = csv.reader(csvfile, delimiter=',')
        print("*************************************STATS", year_to_check)
        for row in rows: 
            year = row[1]
            if year == year_to_check:
                #print("[Id, Year, MaleCount, FemaleCount, UnknownCount, TotNames, Male%, Female%, Unknown%]")
                print("Old stats: ", row)
                #print(compensationArray)
                maleCount = int(row[2]) + compensationArray[0]
                femaleCount = int(row[3]) + compensationArray[1]
                UnknownCount = int(row[4]) + compensationArray[2]
                TotNames = int(row[5]) + compensationArray[3]
                newLine = [int(row[0]), int(year), maleCount, femaleCount, UnknownCount, TotNames, maleCount/TotNames, femaleCount/TotNames, UnknownCount/TotNames]
                #print(newLine)
                return(newLine) 

def iterateThroughYears(year):
    #print(type(str(year)), type("1975"))
    #year = "1975"
    year = str(year)
    print("*************************************", year)
    allPersonsOneYear = getNamesFromCSV(year)
    compensation = findDuplicates(allPersonsOneYear)
    fixedYear = fixStatsFile(statsData,year,compensation)
    print("New stats: ", fixedYear)
    return(fixedYear)

def saveNewStats(data): 
    if (data == None):
        print("NO DATA FOR THIS YEAR")
    else:
        print("SAVING DATA")
        outputWriter.writerow(data)

def main():
    print("----------------------------START---------------------------------")
    output = []
    outputWriter.writerow(["Id", "Year", "MaleCount", "FemaleCount", "UnknownCount", "TotNames", "Male%", "Female%", "Unknown%"])
    for i in years[1:3]: # reduce for debugging
        newLine = iterateThroughYears(i)
        saveNewStats(newLine)
        output.append(iterateThroughYears(i))

main()
