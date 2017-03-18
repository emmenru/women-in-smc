import csv
import os
import sys
import pprint

# save log file
# run using python CorrectUnknowns.py > SMC_log.txt


PAPER_TITLE_CSV_COLUMN_INDEX = 7
YEAR_CSV_COLUMN_INDEX = 5
ROW_INDEX_CSV_COLUMN_INDEX = 0  # Stupid.


def output_complete_csv(conference_data,output_csv):
    with open(output_csv, 'wb') as csvfile:
        csv_writer = csv.writer(csvfile, delimiter=',')
        for row in conference_data:
            csv_writer.writerow(row)


def get_conference_data(incomplete_conference_csv):
    data = []
    with open(incomplete_conference_csv, 'rb') as conference_csv:
        csv_reader = csv.reader(conference_csv, delimiter=',')
        for row in csv_reader:
            data.append(row)
    return data


def correct_author_gender(row, author_name, correct_gender):
    """
    If there are multiple occurrences of the author_name
    all authors in the paper's will have their gender corrected
    """
    author_found = []
    for index, cell in enumerate(row):
        if cell == author_name:
            row[index+1] = correct_gender
            author_found.append(index+1)

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


def print_conference_stats(conference_data,
                           output_file_name,
                           num_gender_columns,
                           has_probability):
    GENDER_COLUMNS = [3, 10, 12, 14, 16, 18, 20, 22, 24,
                      26, 28, 30, 32, 34, 36, 38, 40]
    PROBABILITY_COLUMNS = range(41,58)

    gender_dict = {
        'female': 0,
        'male': 0,
        'none': 0
    }
    year_dict = {}

    low_probability_name = 0

    for row in conference_data[1:]:

        # Which year
        row_year = row[YEAR_CSV_COLUMN_INDEX]

        # Initialize that year's dict in year_dict if not present
        if not year_dict.get(row_year):
            # Copy of gender_dict format
            year_dict[row_year] = gender_dict.copy()

        # Variable for convenience
        year_gender_dict = year_dict[row_year]

        #print "Counting on row", row[0]
        for column_index in GENDER_COLUMNS[0:num_gender_columns]:
            # Count for each gender in dict
            for key in gender_dict:
                if row[column_index].strip().lower() == key:
                    year_gender_dict[key] += 1
                    #print "   Hit on ", key, "|", column_index, gender_dict

        # Don't calculate probability if dataset has none
        if not has_probability:
            continue

        for column_index in PROBABILITY_COLUMNS:
                try:
                    probability = float(row[column_index].strip())
                    if probability < 0.8:
                        low_probability_name += 1
                except ValueError as error:
                    # print "Could not convert to float: %s" % (error)
                    continue

    #print "\n\nCalculating gender statistics"
    # Take keys from year_dict and sort them

    years = [int(y) for y in year_dict]
    years.sort()

    with open(output_file_name, 'wb') as csvfile:
        csv_writer = csv.writer(csvfile, delimiter=',')
        csv_writer.writerow(['Year','MaleCount','FemaleCount','UnknownCount','TotNames','Male','Female','Unknown'])
        male_count = 0
        female_count = 0
        none_count = 0
        tot_names_count = 0
        for year in years:
            #print year
            year_str = str(year)
            tot_authors =  year_dict[year_str]['male'] + year_dict[year_str]['female'] + year_dict[year_str]['none']
            tot_names_count += tot_authors
            male_rate = float(year_dict[year_str]['male']) / tot_authors
            male_count +=  year_dict[year_str]['male']
            female_rate = float(year_dict[year_str]['female']) / tot_authors
            female_count +=  year_dict[year_str]['female']
            none_rate = float(year_dict[year_str]['none']) / tot_authors
            none_count +=  year_dict[year_str]['none']
            csv_writer.writerow([
                year,
                year_dict[year_str]['male'],
                year_dict[year_str]['female'],
                year_dict[year_str]['none'],
                tot_authors,
                male_rate,
                female_rate,
                none_rate])

            # for gender in year_dict[year_str]:
            #     print "  %s: %s" % (gender,
            #                         year_dict[year_str][gender])

        csv_writer.writerow(['TotCount' ,
            male_count,
            female_count,
            none_count,
            tot_names_count])

        csv_writer.writerow(['Tot%' ,
            float(male_count) / tot_names_count,
            float(female_count) / tot_names_count,
            float(none_count) / tot_names_count,
            float(tot_names_count) / tot_names_count])

        csv_writer.writerow(['TotArticles',
            len(conference_data)])

        csv_writer.writerow(['NamesLowProb',
            low_probability_name])



def lookup_author_gender(output_csv,
                         incomplete_conference_csv,
                         gender_lookup_csv,
                         output_stats_corrected_csv,
                         output_stats_noncorrected_csv,
                         columns,
                         has_probability=False):
    conf_data = get_conference_data(incomplete_conference_csv)
    # Array slizing to get copy of list (actually copy of list of lists)
    noncorrected_conf_data = conf_data[:]
    # function for counting data in uncorrected file
    print_conference_stats(conf_data,
                           output_stats_noncorrected_csv,
                           columns,
                           has_probability)
    print "Going through CSV with correct author gender"
    i = 0
    with open(gender_lookup_csv, 'rb') as gender_csv:
        print i
        csv_reader = csv.reader(gender_csv, delimiter=',')
        csv_reader.next()
        for name, gender, title, _ in csv_reader:
            index = amend_data(conf_data, title, name, gender)
        i += 1
    #print "\n" * 10
    output_complete_csv(conf_data, output_csv)
    print_conference_stats(conf_data,
                           output_stats_corrected_csv,
                           columns,
                           has_probability)

if __name__ == '__main__':
    lookup_author_gender(output_csv,
        incomplete_conference_csv,
        gender_lookup_csv,
        output_stats_corrected_csv,
        output_stats_noncorrected_csv,
        columns,
        has_probability)