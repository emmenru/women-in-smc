# coding: utf8
import CorrectUnknowns
import os

# TO DO:
# NIME_Corrected output is currently containing genders that sometimes contain spaces (e.g. " male")
# Either change in input file "'NIMEgenderOutputAmbiguous&Unknowns.csv" or fix this in script
# NIME data has "countryFirstauthor" for the first entries, then conference location

#SMC
SMC_csv_path =  'input_data'
SMC_csv_path_out = 'output_data'


SMC_output_csv = os.path.join(SMC_csv_path_out,'SMC_Corrected.csv')
SMC_incomplete_conference_csv = os.path.join(SMC_csv_path,'SMC_NonCorrected_2004-2016.csv')
SMC_gender_lookup_csv = os.path.join(SMC_csv_path,'SMCgenderOutputUnknowns&Ambigous_2004-2016.csv')
SMC_output_stats_corrected_csv = os.path.join(SMC_csv_path_out,'SMC_Stats_Corrected.csv')
SMC_output_stats_noncorrected_csv= os.path.join(SMC_csv_path_out,'SMC_Stats_Non_Corrected.csv')
SMC_columns = 17

CorrectUnknowns.lookup_author_gender(
    SMC_output_csv,
    SMC_incomplete_conference_csv,
    SMC_gender_lookup_csv,
    SMC_output_stats_corrected_csv,
    SMC_output_stats_noncorrected_csv,
    SMC_columns,
    True)

# NIME
# OBS: script for generating NIME output data (GenderPrediction) does not give empty starting column (need to add new empty column if re-running Gender prediction script)
NIME_csv_path = 'input_data'
NIME_csv_path_out = 'output_data'

NIME_output_csv = os.path.join(NIME_csv_path_out,'NIME_Corrected.csv')
NIME_incomplete_conference_csv = os.path.join(NIME_csv_path,'NIME_NonCorrected_2001-2016.csv')
NIME_gender_lookup_csv = os.path.join(NIME_csv_path,'NIMEgenderOutputAmbiguous&Unknowns_2001-2016.csv')
NIME_output_stats_corrected_csv = os.path.join(NIME_csv_path_out,'NIME_Stats_Corrected.csv')
NIME_output_stats_noncorrected_csv= os.path.join(NIME_csv_path_out,'NIME_Stats_Non_Corrected.csv')
NIME_columns=17

CorrectUnknowns.lookup_author_gender(
    NIME_output_csv,
    NIME_incomplete_conference_csv,
    NIME_gender_lookup_csv,
    NIME_output_stats_corrected_csv,
    NIME_output_stats_noncorrected_csv,
    NIME_columns,
    True)

#ICMC
ICMC_csv_path = 'input_data'
ICMC_csv_path_out = 'output_data'

ICMC_output_csv = os.path.join(ICMC_csv_path_out,'ICMC_Corrected.csv')
ICMC_incomplete_conference_csv = os.path.join(ICMC_csv_path,'ICMC_NonCorrected_1975-2016.csv')
ICMC_gender_lookup_csv = os.path.join(ICMC_csv_path,'ICMCgenderOutputAmbiguous&Unknowns_1975-2016.csv')
ICMC_output_stats_corrected_csv = os.path.join(ICMC_csv_path_out,'ICMC_Stats_Corrected.csv')
ICMC_output_stats_noncorrected_csv= os.path.join(ICMC_csv_path_out,'ICMC_Stats_Non_Corrected.csv')
ICMC_columns=17

CorrectUnknowns.lookup_author_gender(
    ICMC_output_csv,
    ICMC_incomplete_conference_csv,
    ICMC_gender_lookup_csv,
    ICMC_output_stats_corrected_csv,
    ICMC_output_stats_noncorrected_csv,
    ICMC_columns,
    True)
