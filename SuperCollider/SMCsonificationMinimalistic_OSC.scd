// up to 14 authors for SMC, 10 authors for NIME, 17 for ICMC


//////////////////////// ISSUES ////////////////////////
// there are some " in the columns..... why?

// watch out for the title and place columns
// they sometimes contain commas which fucks up the csv reader

// IMPORTANT! CELLS ARE NOT ALLOWED TO BE EMPTY!
// The last row in the data set always get a "male" for the last column if cells are empty (I don't understand why!)
// Fill cells with zeroes and there should be no problem
// the filereader fucks up for special characters and citation marks, clean the data before sonifying

//////////////////////// TO DO ////////////////////////
// PUT OSC ON MALE AUTHORS TOO - now year changes depending on female authors
// in order to illustrate the difference in numbers: make two versions:
// this is what it would sound like if it was the other way around: one where the male voices are set to the female synth

//////////////////////// SYNTH DEFINITIONS////////////////////////
s.boot();



(
(
SynthDef.new(\mymalesynth, {
	arg hz=340, atk=0.05, rel=0.05, amp, pan=0;
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
SynthDef(\female, {|out = 0, year, hz = 1760, amp, dur, pan|
	var chain, onsets;
    var sig = Resonz.ar(
		Array.fill(4, {Impulse.ar(0)}),  // returns 4 impulses
	    hz  * [1, 2, 4, 8], // frequency
	    0.01).sum*10; // Q ?
	var env = EnvGen.kr(Env.perc(0.0001, dur, amp, -4), doneAction:2);
	sig = sig * env;
	sig = Pan2.ar(sig, pan);
	Out.ar(0, sig);
	chain = FFT({LocalBuf(512, 1)}, sig);
	onsets = Onsets.kr(chain,0.1,\power);
	SendTrig.kr(onsets,year);
}).add
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
//~text = CSVFileReader.read("/Users/emmafrid/Dev/women-in-smc/input_data_SuperCollider/ICMC_Corrected_Numeric.csv", true).postcs; // true for skipping empty rows (do not skip empty cells!!!)

~text = CSVFileReader.read("/Users/emmafrid/Dev/women-in-smc/2021_update/output/corrected_output_supercollider/ICMCgenderOutput_2021_for_R_SC.csv", true).postcs;



// invert rows and columns in a two dimensional Array
// this is done to get a vector of each column rather than a vector of each row
~text=~text.flop;

// place is where the conference toke place
~place=~text[2].drop(1);
~year=~text[3].drop(1).collect(_.asInteger);

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

// print all columns to make sure that the data contains only gender data
//~text[1].postln;
//~gender2_female.do({arg item, counter; counter.post; " : ".post; item.postln;});
)


// FOR DEBUGGING CSV VALUES
// ~gender_female = Array.new(17);
// ~gender_female.add(~text[0]);
// (6,8..36).do({ arg item; ~gender_female.add(~text[item]) });  // drop(1) is to drop column name
// ~gender_female[1]


//////////////////////// SET PARAMETERS FOR SOUND SYNTHESIS ////////////////////////

(
// local variables
var freq_fact_female,freq_fact_male,randomization_female,randomization_male,amp_fact_female,amp_fact_male,amp_dec_fact_male;

freq_fact_female = 800;
freq_fact_male = 60;

amp_fact_female=1.0; // amplitude is the same for all female sounds
amp_fact_male=0.5; // amplitude is not the same for all male sounds
amp_dec_fact_male = 0.6; // amp is reduced for second, third .... 17th author

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
~min_dur=0.05;
~max_dur=0.10;

~freqs_female = Array.new(17);
~freqs_male = Array.new(17);
~freqs_male_rand = Array.new(17);
~amps_female = Array.new(17);
~amps_male = Array.new(17);
~freqs_female_rand = Array.new(17);
~panning_female_rand = Array.new(17);


n=size(~gender_female[0]); // length of gender columns
//plot(~gender_female.asInteger)
~length = n; // number of rows to be sonified, should be set to n to sonify entire data set

// DEFINE FREQUENCIES
//assign female frequencies
// 1st version
// frequency fact is multiplied by (item+1) so that increased column no gives increased frequency
//(0..16).do({ arg item; ~freqs_female.add( ((~gender_female[item]).asInteger)*freq_fact_female*(item+1)) });
// add randomization for female frequencies
//(0..16).do({ arg item; (~freqs_female_rand.add(Array.fill(~length, {exprand(1.0, randomization_female)})*~freqs_female[item])) });


// 2nd version
// add randomization (using todi scale) for female frequencies
// this needs to be done within the loop! it is nested!
(0..16).do({
	arg i; ~freqs_female_rand.add(((Array.fill(~length, {arg item; Scale.todi(\just).degreeToFreq(rrand(0,12), 60.midicps, 1)}))*(~gender_female[i].asInteger)).postln)

});

// assign male frequencies
//(0..16).do({ arg item; ~freqs_male.add( ((~gender_male[item]).asInteger)*freq_fact_male) });
// add randomization for male frequencies
//(0..16).do({ arg item; (~freqs_male_rand.add(Array.fill(~length, {exprand(1.0, randomization_male)})*~freqs_male[item])) });
(0..16).do({
	arg i; ~freqs_male_rand.add(((Array.fill(~length, {arg item; Scale.todi(\just).degreeToFreq(rrand(0,12), 12.midicps, 1)}))*(~gender_male[i].asInteger)).postln)

});

// DEFINE AMPLITUDES
//assign female amps
(0..16).do({ arg item; ~amps_female.add( (Array.fill(~length,amp_fact_female)*~gender_female[item].asInteger.normalize)) });
//assign male amps
// amplitude should decrease for every item in the list (for every gender column)
(0..16).do({ arg item; ~amps_male.add( (Array.fill(~length,amp_fact_male/((item+1)*amp_dec_fact_male))*~gender_male[item].asInteger.normalize)) });

// RANDOMIZE PANNING
(0..16).do({
	arg i; ~panning_female_rand.add(((Array.fill(~length, {arg item; 1.0.rand2}))*(~gender_female[i].asInteger)).postln)
});

)




//////////////////////// CONTINUOUS SONIFICATION ////////////////////////

//s.plotTree
//s.scope;

// consider running this twice
(
// ADD REVERB
// much better to put reverb on the output chain since putting them inside a synth def is demanding
z = Synth(\FreeVerb2x2, [\outbus, 0], addAction:\addToTail);
// experiment with some settings
z.set(\room, 0.9) ;// room size
z.set(\mix, 0.2) ;// dry wet
z.set(\damp, 0.2) ;// reverb HF damp
)



(
	var gender1_female, gender2_female, gender3_female,gender4_female,gender5_female,gender6_female,gender7_female,gender8_female,gender9_female,gender10_female,gender11_female, gender12_female, gender13_female, gender14_female, gender15_female, gender16_female, gender17_female,

gender1_male,gender2_male,gender3_male,gender4_male,gender5_male,gender6_male,gender7_male,gender8_male,gender9_male,gender10_male,gender11_male, gender12_male, gender13_male, gender14_male, gender15_male, gender16_male, gender17_male;


//// FEMALE VOICES

	gender1_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_female_rand[0]), // use trace to print out the current values
	\amp, Pseq(~amps_female[0]),
	\pan, Pseq(~panning_female_rand[0]),
	\year, Pseq(~year).trace;
);

	gender2_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_female_rand[1]),
	\amp, Pseq(~amps_female[1]),
	\pan, Pseq(~panning_female_rand[1])
);

	gender3_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_female_rand[2]),
	\amp, Pseq(~amps_female[2]),
	\pan, Pseq(~panning_female_rand[2])
);

gender4_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_female_rand[3]),
	\amp, Pseq(~amps_female[3]),
	\pan, Pseq(~panning_female_rand[3])
);


gender5_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_female_rand[4]),
	\amp, Pseq(~amps_female[4]),
	\pan, Pseq(~panning_female_rand[4])
);


gender6_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_female_rand[5]),
	\amp, Pseq(~amps_female[5]),
	\pan, Pseq(~panning_female_rand[5])
);


gender7_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_female_rand[6]),
	\amp, Pseq(~amps_female[6]),
	\pan, Pseq(~panning_female_rand[6]),
	\pan, Pseq(~panning_female_rand[6]),
	\year, Pseq(~year)
);


gender8_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_female_rand[7]),
	\amp, Pseq(~amps_female[7]),
	\pan, Pseq(~panning_female_rand[7])
);


gender9_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_female_rand[8]),
	\amp, Pseq(~amps_female[8]),
	\pan, Pseq(~panning_female_rand[8])
);


gender10_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_female_rand[9]),
	\amp, Pseq(~amps_female[9]),
	\pan, Pseq(~panning_female_rand[9])
);

gender11_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_female_rand[10]),
	\amp, Pseq(~amps_female[10]),
	\pan, Pseq(~panning_female_rand[10])
);

gender12_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_female_rand[11]),
	\amp, Pseq(~amps_female[11]),
	\pan, Pseq(~panning_female_rand[11])
);

gender13_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_female_rand[12]),
	\amp, Pseq(~amps_female[12]),
	\pan, Pseq(~panning_female_rand[12])
);

gender14_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_female_rand[13]),
	\amp, Pseq(~amps_female[13]),
	\pan, Pseq(~panning_female_rand[13])
);

gender15_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_female_rand[14]),
	\amp, Pseq(~amps_female[14]),
	\pan, Pseq(~panning_female_rand[14])
);

gender16_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_female_rand[15]),
	\amp, Pseq(~amps_female[15]),
	\pan, Pseq(~panning_female_rand[15])
);

gender17_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_female_rand[16]),
	\amp, Pseq(~amps_female[16]),
	\pan, Pseq(~panning_female_rand[16])
);



//// MALE VOICES


	gender1_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[0]),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[0]),
	\year, Pseq(~year).trace;
);

	gender2_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[1]),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[1])
);

	gender3_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[2]),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[2])
);

	gender4_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[3]),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[3])
);

	gender5_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[4]),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[4])
);

	gender6_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[5]),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[5])
);

	gender7_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[6]),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[6])
);

	gender8_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[7]),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[7])
);

	gender9_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[8]),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[8])
);

	gender10_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[9]),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[9])
);

	gender11_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[10]),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[10])
);


	gender12_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[11]),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[11])
);


	gender13_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[12]),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[12])
);


	gender14_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[13]),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[13])
);


	gender15_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[14]),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[14])
);



	gender16_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[15]),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[15])
);



	gender17_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~freqs_male_rand[16]),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps_male[16])
);



// The voices originating from the same order in gender detection should be played simultaenously (no shift in time)
// when adding multiple columns, the voices should be presented with time delay for each column

 Ptpar([
	0.0, gender1_female,
	0.0, gender1_male,
	0.1, gender2_female,
	0.1, gender2_male,
	0.15,gender3_female,
	0.15,gender3_male,
	0.20,gender4_female,
	0.20,gender4_male,
	0.25,gender5_female,
	0.25,gender5_male,
	0.30,gender6_female,
	0.30,gender6_male,
	0.35,gender7_female,
	0.35,gender7_male,
	0.40,gender8_female,
	0.40,gender8_male,
	0.45,gender9_female,
	0.45,gender9_male,
	0.50,gender10_female,
	0.50,gender10_male,
	0.55,gender11_female,
	0.55,gender11_male,
	0.60,gender12_female,
	0.60,gender12_male,
	0.65,gender13_female,
	0.65,gender13_male,
	0.70,gender14_female,
	0.70,gender14_male,
	0.75,gender15_female,
	0.75,gender15_male,
	0.80,gender16_female,
	0.80,gender16_male,
	0.85,gender17_female,
	0.85,gender17_male
],1).play; // use Ptpar to change wait between trigger of different voices


)


~host = NetAddr("localhost", 4859); // address de PROCESSING

o = OSCFunc({ arg msg, time; var sendMess, year;
	year= [msg][0][2];
	~host.sendMsg("/trigger",year,1.0,"smc");
},'/tr', s.addr);