import csv
import os
import sys
import pprint

CSV_PATH = 'Data/SMCoutput/OnePackage-genderize.io'
INCOMPLETE_CONFERENCE_CSV = os.path.join(
    CSV_PATH,
    'SMCgenderOutput_beforeFixingUnknowns.csv')
GENDER_LOOKUP_CSV = os.path.join(
    CSV_PATH,
    'SMCgenderOutputUnknowns&Ambigous.csv')
OUTPUT_CSV = os.path.join(
    CSV_PATH,
    'SMC_Corrected.csv')
PAPER_TITLE_CSV_COLUMN_INDEX = 7
YEAR_CSV_COLUMN_INDEX = 5
ROW_INDEX_CSV_COLUMN_INDEX = 0  # Stupid.


def output_complete_csv(conference_data):
    with open(OUTPUT_CSV, 'wb') as csvfile:
        csv_writer = csv.writer(csvfile, delimiter=',')
        for row in conference_data:
            csv_writer.writerow(row)


def get_conference_data():
    data = []
    with open(INCOMPLETE_CONFERENCE_CSV, 'rb') as conference_csv:
        csv_reader = csv.reader(conference_csv, delimiter=',')
        for row in csv_reader:
            data.append(row)
    return data


def correct_author_gender(row, author_name, correct_gender):
    author_found = 0
    for index, cell in enumerate(row):
        if cell == author_name:
            if not author_found:
                row[index+1] = correct_gender
                author_found = index+1
            else:
                print "Author name appears more than once in paper row!"
                sys.exit(1)
    return author_found


def amend_data(data,
               paper_title,
               author_name,
               gender):
    print "Correcting paper \"%s\" author %s's gender (%s)" % (paper_title,
                                                                author_name,
                                                                gender)
    for index, row in enumerate(data):
        if paper_title == row[PAPER_TITLE_CSV_COLUMN_INDEX]:
            col_index = correct_author_gender(data[index], author_name, gender)
            print "Corrected column %s in row %s in conference csv data" % (
                col_index, index)
            return index
    print "Did not find paper!"
    sys.exit(1)


def print_conference_stats(conference_data):
    GENDER_COLUMNS = [3, 10, 12, 14,16, 18, 20, 22, 24,
                      26, 28, 30, 32, 34, 36, 38, 40]
    gender_dict = {
        'female': 0,
        'male': 0,
        'none': 0
    }
    year_dict = {}

    for row in conference_data[1:]:

        # Which year
        row_year = row[YEAR_CSV_COLUMN_INDEX]

        # Initialize that year's dict in year_dict if not present
        if not year_dict.get(row_year):
            year_dict[row_year] = gender_dict.copy()

        # Variable for convenience
        year_gender_dict = year_dict[row_year]

        print "Counting on row", row[0]
        for column_idx in GENDER_COLUMNS:
            # Count for each gender in dict
            for key in gender_dict:
                if row[column_idx].strip().lower() == key:
                    year_gender_dict[key] += 1
                    print "   Hit on ", key, "|", column_idx, gender_dict

    print "\n\nGender statistics:"
    years = [int(y) for y in year_dict]
    years.sort()
    for year in years:
        print year
        year_str = str(year)
        for gender in year_dict[year_str]:
            print "  %s: %s" % (gender,
                                year_dict[year_str][gender])


def lookup_author_gender():
    conf_data = get_conference_data()

    print "Going through CSV with correct author gender"
    with open(GENDER_LOOKUP_CSV, 'rb') as gender_csv:
        csv_reader = csv.reader(gender_csv, delimiter=',')
        csv_reader.next()
        for name, gender, title, _, _ in csv_reader:
            if name.lower() == "unknown":
                continue
            idx = amend_data(conf_data, title, name, gender)
            print
    print "\n" * 10
    #output_complete_csv(conf_data)
    print_conference_stats(conf_data)

if __name__ == '__main__':
    lookup_author_gender()