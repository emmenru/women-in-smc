# coding: utf8
import CorrectUnknowns
import os

# The Music, Technology and Innovation Research Group (MTIRG) at De Montfort University ‰ЫХ Studio Report

# SMC
SMC_csv_path = 'Data/SMCoutput/OnePackage-genderize.io'
SMC_incomplete_conference_csv = os.path.join(SMC_csv_path,'SMC_NonCorrected.csv')
SMC_gender_lookup_csv = os.path.join(SMC_csv_path,'SMCgenderOutputUnknowns&Ambigous.csv')
SMC_output_csv = os.path.join(SMC_csv_path,'SMC_Corrected.csv')
SMC_output_stats_corrected_csv = os.path.join(SMC_csv_path,'SMC_Stats_Corrected.csv')
SMC_output_stats_noncorrected_csv= os.path.join(SMC_csv_path,'SMC_Stats_Non_Corrected.csv')
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
NIME_csv_path = 'Data/NIMEoutput/OnePackage-genderize.io'
NIME_incomplete_conference_csv = os.path.join(NIME_csv_path,'NIME_NonCorrected.csv')
NIME_gender_lookup_csv = os.path.join(NIME_csv_path,'NIMEgenderOutputAmbiguous&Unknowns.csv')
NIME_output_csv = os.path.join(NIME_csv_path,'NIME_Corrected.csv')
NIME_output_stats_corrected_csv = os.path.join(NIME_csv_path,'NIME_Stats_Corrected.csv')
NIME_output_stats_noncorrected_csv= os.path.join(NIME_csv_path,'NIME_Stats_Non_Corrected.csv')
NIME_columns=10
# NIME only has 10 Columns

CorrectUnknowns.lookup_author_gender(
    NIME_output_csv,
    NIME_incomplete_conference_csv,
    NIME_gender_lookup_csv,
    NIME_output_stats_corrected_csv,
    NIME_output_stats_noncorrected_csv,
    NIME_columns)

# ICMC
ICMC_csv_path = 'Data/ICMCoutput/OnePackage-genderize.io'
ICMC_incomplete_conference_csv = os.path.join(ICMC_csv_path,'ICMC_NonCorrected.csv')
ICMC_gender_lookup_csv = os.path.join(ICMC_csv_path,'ICMCgenderOutputAmbiguous&Unknowns.csv')
ICMC_output_csv = os.path.join(ICMC_csv_path,'ICMC_Corrected.csv')
ICMC_output_stats_corrected_csv = os.path.join(ICMC_csv_path,'ICMC_Stats_Corrected.csv')
ICMC_output_stats_noncorrected_csv= os.path.join(ICMC_csv_path,'ICMC_Stats_Non_Corrected.csv')
ICMC_columns=17

CorrectUnknowns.lookup_author_gender(
    ICMC_output_csv,
    ICMC_incomplete_conference_csv,
    ICMC_gender_lookup_csv,
    ICMC_output_stats_corrected_csv,
    ICMC_output_stats_noncorrected_csv,
    ICMC_columns,
    True)
