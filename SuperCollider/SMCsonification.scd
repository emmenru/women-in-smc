

s.boot()


// to do:
// add  voices for all gender columns
// fix synth definitions so that it sounds drony and good (search online)
// perhaps percussion or plucking would be nice for female voices
// add panning depending on wich conference it is
// add reverb on overall output bus

// the gender1_female synth does not play the first frequency, but all of the rest of them...

////////////////////////
/// SYNTH DEFINITIONS
////////////////////////

// make this into randomized noises of chimes or glass or percussion
(
 SynthDef(\myfemalesynth, {|out = 0, freq, amp, dur, pan = 0, mod = 50|
  var pm, modulator, env, panner;

  modulator = PinkNoise.ar(mod, 0, 0.1);
 pm = SinOsc.ar(freq, modulator);
 pm = { Klank.ar(`[ {exprand(freq*5, freq*1000)}.dup(12), nil, nil ], PinkNoise.ar(0.009)) };

  env = EnvGen.kr(Env.perc(0.1, dur, amp), doneAction:2);
  panner = Pan2.ar(pm, pan, env);

  Out.ar(out, panner);
 }).store
)


// Something drony
// add so that it sounds like rain
// add an echo effect
(
SynthDef.new(\mymalesynth, {
	arg hz=340, atk=0.05, rel=0.3, amp=1, pan=0;
	var sig, env;
	sig = SinOsc.ar(hz);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)


(
SynthDef.new(\wooden, {
	arg freq=420, rq=0.02, amp=1, pan=0;
	var sig;
	sig = Pan2.ar(BPF.ar(WhiteNoise.ar * Line.kr(5, 0, 0.02), freq, rq));
	Out.ar(0, sig);
}).add;
)

Pbind(\instrument, \wooden, \freq, Pseq([40]).midicps, \amp, 0.6).play


(

////////////////////////////////////////////////
// READ DATA INTO 2D-VECTOR
////////////////////////////////////////////////

~text = CSVFileReader.read("/Users/emmafrid/kurser/creative_coding/women-in-smc/SuperCollider/SMCsonificationNumeric.csv", true).postcs; // true for skipping empty rows (do not skip empty cells!!!)

// IMPORTANT! CELLS ARE NOT ALLOWED TO BE EMPTY!
// The last row in the data set always get a "male" for the last column if cells are empty (I don't understand why!)
// Fill cells with zeroes and there should be no problem
// the filereader fucks up for special characters and citation marks, clean the data before sonifying

// invert rows and columns in a two dimensional Array
// this is done to get a vector of each column rather than a vector of each row
~text=~text.flop;

// place
~place=~text[2].drop(1);
~year=~text[3].drop(1);

// gender column values

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
~gender2_female.do({arg item, counter; counter.post; " : ".post; item.postln;});
)

///////////////////////////////////////
/// SOUND SYNTHESIS
///////////////////////////////////////

// FIRST GENDER COLUMN PARAMETERS
(
n=size(~gender1_female); // length of column
//plot(~gender1_female.asInteger)
~length = 200; // number of rows to be sonified ~length=n for entire data set
~note_length = 0.3;
~durs = Array.fill(~length, ~note_length);
// SET FREQUENCIES FOR FEMALE, MALE VERSUS NONE VOICES
~freq_female = 200;
~freq_male = 100;
// frequencies for all gender columns
~freqs1_female = ~gender1_female.asInteger * ~freq_female;
~freqs1_male = ~gender1_male.asInteger * ~freq_male;
~freqs2_female = ~gender2_female.asInteger * ~freq_female;
~freqs2_male = ~gender2_male.asInteger * ~freq_male;


~randomization=2;
~cont_freqs1_female= Array.fill(~length, {exprand(1.0, ~randomization)})*~freqs1_female;
~cont_freqs1_male= Array.fill(~length, {exprand(1.0, ~randomization)})*~freqs1_male;
~cont_freqs2_female= Array.fill(~length, {exprand(1.0, ~randomization)})*~freqs2_female;
~cont_freqs2_male= Array.fill(~length, {exprand(1.0, ~randomization)})*~freqs2_male;


// ADD SOME RANDOMNESS
~min_attack_female=0.1;
~max_attack_female=0.8;
~min_attack_male=0.2;
~max_attack_male=0.25;
~min_release_female=0.5;
~max_release_female=1.0;
~min_release_male=0.5;
~max_release_male=1.0;
// ALSO SET AMPLITUDES FOR THE DIFFERENT VOICES
~amps1_female=Array.fill(~length, 1)*~gender1_female.asInteger.normalize;
~amps1_male=Array.fill(~length, 1)*~gender1_male.asInteger.normalize;
// amplitude multiplication of second ... 17th voices should be lower
~amps2_female_fact=0.6;
~amps2_male_fact=0.5;
// THE LENGTH OF EACH VOICE SHOULD BE THE SAME
~min_length=0.1;
~max_length=0.15;
)


////// CONTINUOUS SONIFICATION

s.boot
s.plotTree

// For one column: one voice per category of gender, i.e. "female", "male"
// each voice has a different synthdef
// These voices should be played simultaenously (no shift in time)
// when adding multiple columns, the voices should be presented with time delay for each column


// in order to illustrate the difference: make three versions:
// this is what it would sound like if it was the other way around: one where the male voices are set to the female synth
// this is what it would sound like if it was 50 % women, 50 % men (randomize so that there is 50 % women in each column

(
	var gender1_female, gender1_male, gender2_female, gender2_male;

	gender1_female = Pbind(
	\instrument, \myfemalesynth,
	\dur, Pwhite(~min_length, ~max_length, ~length),
	\hz, Pseq(~cont_freqs1_female).trace, // use trace to print out the current values
	\atk, Pwhite(~min_attack_female, ~max_attack_female, ~length),
	\rel, Pwhite(~min_release_female, ~max_release_female, ~length),
	\amp, Pseq(~amps1_female)
);


	gender2_female = Pbind(
	\instrument, \myfemalesynth,
	\dur, Pwhite(~min_length, ~max_length, ~length),
	\hz, Pseq(~cont_freqs2_female).trace, // use trace to print out the current values
	\atk, Pwhite(~min_attack_female, ~max_attack_female, ~length),
	\rel, Pwhite(~min_release_female, ~max_release_female, ~length),
	\amp, Pseq(~amps1_female*~amps2_female_fact) // amps of second voice should be lower
);

	gender1_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_length, ~max_length, ~length),
	\hz, Pseq(~cont_freqs1_male),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps1_male)
);

	gender2_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_length, ~max_length, ~length),
	\hz, Pseq(~cont_freqs2_male),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amps1_male*~amps2_male_fact)
);


 Ptpar([ 0.0, gender1_female, 0.1, gender2_female, 0.0, gender1_male,0.1, gender2_male],1).play; // use Ptpar to change wait between trigger of different voices

)








