// up to 14 authors for SMC, 10 authors for NIME, 17 for ICMC

// there are some " in the columns.....

// add todi scale for frequencies on impact

// consider adding a granular synthesizer instead of impact sounds

// IMPORTANT! CELLS ARE NOT ALLOWED TO BE EMPTY!
// The last row in the data set always get a "male" for the last column if cells are empty (I don't understand why!)
// Fill cells with zeroes and there should be no problem
// the filereader fucks up for special characters and citation marks, clean the data before sonifying


//////////////////////// SYNTH DEFINITIONS////////////////////////
s.boot();
(
(
SynthDef.new(\mymalesynth, {
	arg hz=340, atk=0.05, rel=0.05, amp=1, pan=0;
	var sig, env;
	sig = SinOsc.ar(hz);
	//sig = SinOsc.ar(Gendy2.ar(6.rand,6.rand,SinOsc.kr(0.1,0,0.49,0.51),SinOsc.kr(0.13,0,0.49,0.51),hz ,hz, SinOsc.kr(0.17,0,0.49,0.51), SinOsc.kr(0.19,0,0.49,0.51), 5, 12, 0.4.rand, 0.4.rand, 300, 500), 0, 0.1);
	env = EnvGen.kr(Env.new([0,0.4,0],[atk,rel],[0.8,-0.8]),doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;

);


(
SynthDef(\female, {|out = 0, hz = 1760, amp, dur, pan = 0|
    var sig = Resonz.ar(Array.fill(4, {Impulse.ar(0)}), hz  * [1, 2, 4, 8], 0.01).sum*10;
	var env = EnvGen.kr(Env.perc(0.02, dur, amp), doneAction:2);
    sig = Pan2.ar(sig, pan, amp);
	Out.ar(0, sig);}).add
);


(
SynthDef(\FreeVerb2x2, {|outbus, mix = 0.25, room = 0.15, damp = 0.5, amp = 1.0|
    var signal;

    signal = In.ar(outbus, 2);

    ReplaceOut.ar(outbus,
        FreeVerb2.ar( // FreeVerb2 - true stereo UGen
            signal[0], // Left channel
            signal[1], // Right Channel
            mix, room, damp, amp)); // same params as FreeVerb 1 chn version

}).add;
);

)

//////////////////////// READ DATA  INTO 2D VECTOR ////////////////////////
(
~text = CSVFileReader.read("/Users/emmafrid/kurser/creative_coding/women-in-smc/input_data_SuperCollider/SMC_Corrected_Numeric.csv", true).postcs; // true for skipping empty rows (do not skip empty cells!!!)

// invert rows and columns in a two dimensional Array
// this is done to get a vector of each column rather than a vector of each row
~text=~text.flop;

// place is where the conference toke place
~place=~text[2].drop(1);
~year=~text[3].drop(1);

// specify gender column values here (1 = gender occurance for specific column)
// exceptions

// male gender columns
~gender_male = Array.new(17);
~gender_male.add(~text[1].drop(1));
(7,9..37).do({ arg item; ~gender_male.add(~text[item].drop(1)) });  // drop(1) is to drop column name
// ~gender_male[16].postln; // final male column


// female gender columns
~gender_female = Array.new(17);
~gender_female.add(~text[0].drop(1));
(6,8..36).do({ arg item; ~gender_female.add(~text[item].drop(1)) });  // drop(1) is to drop column name


// this should be removed and re-done
~gender1_female=~text[0].drop(1);
~gender1_male=~text[1].drop(1);

~gender2_female=~text[6].drop(1);
~gender2_male=~text[7].drop(1);
~gender3_female=~text[8].drop(1);
~gender3_male=~text[9].drop(1);
~gender4_female=~text[10].drop(1);
~gender4_male=~text[11].drop(1);
~gender5_female=~text[12].drop(1);
~gender5_male=~text[13].drop(1);
~gender6_female=~text[14].drop(1);
~gender6_male=~text[15].drop(1);
~gender7_female=~text[16].drop(1);
~gender7_male=~text[17].drop(1);
~gender8_female=~text[18].drop(1);
~gender8_male=~text[19].drop(1);
~gender9_female=~text[20].drop(1);
~gender9_male=~text[21].drop(1);
~gender10_female=~text[22].drop(1);
~gender10_male=~text[23].drop(1);
~gender11_female=~text[24].drop(1);
~gender11_male=~text[25].drop(1);
~gender12_female=~text[26].drop(1);
~gender12_male=~text[27].drop(1);
~gender13_female=~text[28].drop(1);
~gender13_male=~text[29].drop(1);
~gender14_female=~text[30].drop(1);
~gender14_male=~text[31].drop(1);
~gender15_female=~text[32].drop(1);
~gender15_male=~text[33].drop(1);
~gender16_female=~text[34].drop(1);
~gender16_male=~text[35].drop(1);
~gender17_female=~text[36].drop(1);
~gender17_male=~text[37].drop(1);



// print all columns to make sure that the data contains only gender data
//~text[1].postln;
//~gender2_female.do({arg item, counter; counter.post; " : ".post; item.postln;});
)



//////////////////////// SOUND SYNTHESIS ////////////////////////

// FIRST GENDER COLUMN PARAMETERS
(
// local variables
var freq_fact_female,freq_fact_male,randomization_female,randomization_male,amp_fact_female,amp_fact_male;

freq_fact_female = 800;
freq_fact_male = 60;

amp_fact_female=0.8; // amplitude is the same for all female sounds
amp_fact_male=1.0; // amplitude is not the same for all female sounds

randomization_female=1.5;
randomization_male=2;

// global variables
// envelope parameters
// increase these values to get a drone sound, decrease them to get separated notes
~min_attack_male=0.3;
~max_attack_male=0.4;
~min_release_male=0.3;
~max_release_male=0.4;
// duration of notes
// this defines how fast it goes since it sets the length of each sound
~min_dur=0.10;
~max_dur=0.25;

~freqs_female = Array.new(17);
~freqs_male = Array.new(17);
~freqs_male_rand = Array.new(17);
~amps_female = Array.new(17);
~amps_male = Array.new(17);
~freqs_female_rand = Array.new(17);

n=size(~gender_female[0]); // length of gender columns
//plot(~gender_female.asInteger)
~length = n; // number of rows to be sonified, should be set to n to sonify entire data set
~note_length = 0.1; //
~durs = Array.fill(~length, ~note_length);

// DEFINE FREQUENCIES
//assign female frequencies
(0..16).do({ arg item; ~freqs_female.add( ((~gender_female[item]).asInteger)*freq_fact_female) });
// add randomization to female frequencies
(0..16).do({ arg item; (~freqs_female_rand.add(Array.fill(~length, {exprand(1.0, randomization_female)})*~freqs_female[item])) });
// assign male frequencies
(0..16).do({ arg item; ~freqs_male.add( ((~gender_male[item]).asInteger)*freq_fact_male) });
// add randomization to male frequencies
(0..16).do({ arg item; (~freqs_male_rand.add(Array.fill(~length, {exprand(1.0, randomization_male)})*~freqs_male[item])) });

// DEFINE AMPLITUDES
//assign female amps
(0..16).do({ arg item; ~amps_female.add( (Array.fill(~length,amp_fact_female)*~gender_female[item].asInteger.normalize)) });
// assign male amps
(0..16).do({ arg item; ~amps_male.add( (Array.fill(~length,amp_fact_male)*~gender_male[item].asInteger.normalize)) });
)


////// CONTINUOUS SONIFICATION

s.plotTree
s.scope;
// For one column: one voice per category of gender, i.e. "female", "male"
// each voice has a different synthdef
// These voices should be played simultaenously (no shift in time)
// when adding multiple columns, the voices should be presented with time delay for each column


// in order to illustrate the difference: make three versions:
// this is what it would sound like if it was the other way around: one where the male voices are set to the female synth
// this is what it would sound like if it was 50 % women, 50 % men (randomize so that there is 50 % women in each column


(
	var gender1_female, gender1_male, gender2_female,gender3_female, gender2_male,gender3_male,gender4_male,gender5_male,gender6_male,gender7_male,gender8_male,gender9_male,gender10_male;

	gender1_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_female_rand[0]).trace, // use trace to print out the current values
	\amp, Pseq(~amps_female[0])
);

	gender2_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_female_rand[1]),
	\amp, Pseq(~amps_female[1]) // amps of second voice should be lower
);

	gender3_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_female_rand[2]),
	\amp, Pseq(~amps_female[2]) // amps of second voice should be lower
);

	gender1_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[0]),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[0])
);

	gender2_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[1]*0.90),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amp_male)
);

	gender3_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[2]*0.80),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[1])
);

	gender4_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[3]*0.7),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[2])
);

	gender5_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[4]*0.6),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[3])
);


	gender6_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[5]*0.5),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[4])
);

	gender7_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[6]*0.4),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[5])
);

	gender8_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[7]*0.3),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[6])
);

	gender8_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[8]*0.25),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[7])
);

	gender9_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[9]*0.15),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[8])
);

	gender10_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[10]*0.1),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[9])
);



 Ptpar([ 0.0, gender1_female, 0.0, gender1_male,0.1, gender2_female, 0.1, gender2_male, 0.15,gender3_male,0.15,gender3_female,0.2,gender4_male,0.25,gender5_male,0.3,gender6_male,0.35,gender7_male,0.4,gender8_male,0.45,gender8_male,0.5,gender9_male,0.55,gender10_male],1).play; // use Ptpar to change wait between trigger of different voices


)


// much better to put reverb on the output chain since putting them inside a synth def is demanding
// r = Synth(\FreeVerb2x2, [\outbus, 0], addAction:\addToTail)

(
// ADD REVERB
z = Synth(\FreeVerb2x2, [\outbus, 0], addAction:\addToTail);
// experiment with some settings
z.set(\room, 0.9) ;// room size
z.set(\mix, 0.3) ;// dry wet
z.set(\damp, 0.2) ;// reverb HF damp
)

//~freqs1_female =  Array.fill(~length, {Scale.todi.degreeToFreq(rrand(0, 12), 60.midicps, 1)})*~freqs1_female;


