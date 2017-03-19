# coding: utf8
import CorrectUnknowns
import os

#SMC
SMC_csv_path = 'Data/SMCoutput/OnePackage-genderize.io'
SMC_csv_path_out = 'output_data'


SMC_output_csv = os.path.join(SMC_csv_path_out,'SMC_Corrected.csv')
SMC_incomplete_conference_csv = os.path.join(SMC_csv_path,'SMC_NonCorrected.csv')
SMC_gender_lookup_csv = os.path.join(SMC_csv_path,'SMCgenderOutputUnknowns&Ambigous.csv')
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
NIME_csv_path = 'input_data'
NIME_csv_path_out = 'output_data'

NIME_output_csv = os.path.join(NIME_csv_path_out,'NIME_Corrected.csv')
NIME_incomplete_conference_csv = os.path.join(NIME_csv_path,'NIME_NonCorrected.csv')
NIME_gender_lookup_csv = os.path.join(NIME_csv_path,'NIMEgenderOutputAmbiguous&Unknowns.csv')
NIME_output_stats_corrected_csv = os.path.join(NIME_csv_path_out,'NIME_Stats_Corrected.csv')
NIME_output_stats_noncorrected_csv= os.path.join(NIME_csv_path_out,'NIME_Stats_Non_Corrected.csv')
NIME_columns=10
# NIME only has 10 Columns

CorrectUnknowns.lookup_author_gender(
    NIME_output_csv,
    NIME_incomplete_conference_csv,
    NIME_gender_lookup_csv,
    NIME_output_stats_corrected_csv,
    NIME_output_stats_noncorrected_csv,
    NIME_columns)

#ICMC
ICMC_csv_path = 'input_data'
ICMC_csv_path_out = 'output_data'

ICMC_output_csv = os.path.join(ICMC_csv_path_out,'ICMC_Corrected.csv')
ICMC_incomplete_conference_csv = os.path.join(ICMC_csv_path,'ICMC_NonCorrected.csv')
ICMC_gender_lookup_csv = os.path.join(ICMC_csv_path,'ICMCgenderOutputAmbiguous&Unknowns.csv')
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
