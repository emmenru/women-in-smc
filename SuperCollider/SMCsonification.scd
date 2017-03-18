

s.boot()


// to do:
// add amps for respective male ... it should not be set to the first author, they should be silent mostly....
// maybe this is not needed. however, now the sounds are triggered by frequency right?

// frequencies and amplitudes etc.
// fix so that variables are in a list
// add todi scale for frequencies on impact

// consider adding a granular synthesizer instead of impact sounds....possibly

// the gender1_female synth does not play the first frequency, but all of the rest of them...
// use trace

// add so that second authors are rain drops
// add up to 14 authors for SMC, 10 authors for NIME, 17 for ICMC

////////////////////////
/// SYNTH DEFINITIONS
////////////////////////

// make this into randomized noises of chimes or glass or percussion


(
 SynthDef(\myfemalesynth, {|out = 0, freq, amp, dur, pan = 0|
  var pm, modulator, env, panner;
 pm = SinOsc.ar(freq);
 pm = { Klank.ar(`[ {exprand(freq*1, freq*5000)}.dup(28), nil, nil ], WhiteNoise.ar(0.01)) };
  env = EnvGen.kr(Env.perc(0.02, dur, amp), doneAction:2);
  panner = Pan2.ar(pm, pan, env);
  Out.ar(out, panner);
 }).add;
)


// Something drony
// add so that it sounds like rain
// add an echo effect
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

)


(
SynthDef(\female, {|out = 0, hz = 1760, amp, dur, pan = 0|
    var sig = Resonz.ar(Array.fill(4, {Impulse.ar(0)}), hz  * [1, 2, 4, 8], 0.01).sum*10;
	var env = EnvGen.kr(Env.perc(0.02, dur, amp), doneAction:2);
    sig = Pan2.ar(sig, pan, amp);
	Out.ar(0, sig);}).add
)


// FreeVerb2
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
)

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
~length = n; // number of rows to be sonified ~length=n for entire data set
~note_length = 0.1;
~durs = Array.fill(~length, ~note_length);
// SET FREQUENCIES FOR FEMALE, MALE VERSUS NONE VOICES
~freq_female = 800;
~freq_male = 60;
// frequencies for all gender columns
~freqs1_female = ~gender1_female.asInteger * ~freq_female;
~freqs2_female = ~gender2_female.asInteger * ~freq_female;
~freqs3_female = ~gender3_female.asInteger * ~freq_female;


// MALE
~freqs1_male = ~gender1_male.asInteger * ~freq_male;
~freqs2_male = ~gender2_male.asInteger * ~freq_male;
~freqs3_male = ~gender3_male.asInteger * ~freq_male;
~freqs4_male = ~gender4_male.asInteger * ~freq_male;
~freqs5_male = ~gender5_male.asInteger * ~freq_male;
~freqs6_male = ~gender6_male.asInteger * ~freq_male;
~freqs7_male = ~gender7_male.asInteger * ~freq_male;
~freqs8_male = ~gender8_male.asInteger * ~freq_male;
~freqs9_male = ~gender9_male.asInteger * ~freq_male;
~freqs10_male = ~gender10_male.asInteger * ~freq_male;


~randomization_female=1.5;
~cont_freqs1_female= Array.fill(~length, {exprand(1.0, ~randomization_female)})*~freqs1_female;
~cont_freqs2_female= Array.fill(~length, {exprand(1.0, ~randomization_female)})*~freqs2_female;
~cont_freqs3_female= Array.fill(~length, {exprand(1.0, ~randomization_female)})*~freqs3_female;

~randomization_male=2;
~cont_freqs1_male= Array.fill(~length, {exprand(1.0, ~randomization_male)})*~freqs1_male;


~cont_freqs2_male= Array.fill(~length, {exprand(1.0, ~randomization_male)})*~freqs2_male;
~cont_freqs3_male= Array.fill(~length, {exprand(1.0, ~randomization_male)})*~freqs3_male;
~cont_freqs4_male= Array.fill(~length, {exprand(1.0, ~randomization_male)})*~freqs4_male;
~cont_freqs5_male= Array.fill(~length, {exprand(1.0, ~randomization_male)})*~freqs5_male;
~cont_freqs6_male= Array.fill(~length, {exprand(1.0, ~randomization_male)})*~freqs6_male;
~cont_freqs7_male= Array.fill(~length, {exprand(1.0, ~randomization_male)})*~freqs7_male;
~cont_freqs8_male= Array.fill(~length, {exprand(1.0, ~randomization_male)})*~freqs8_male;
~cont_freqs9_male= Array.fill(~length, {exprand(1.0, ~randomization_male)})*~freqs9_male;
~cont_freqs10_male= Array.fill(~length, {exprand(1.0, ~randomization_male)})*~freqs10_male;


// ADD SOME RANDOMNESS
// INCREASE THESE VALUES TO GET DRONE
// DECREAE VALUES TO GET SEPARATED NOTES
~min_attack_male=0.3;
~max_attack_male=0.4;
~min_release_male=0.3;
~max_release_male=0.4;
// ALSO SET AMPLITUDES FOR THE DIFFERENT VOICES
~amps1_female=Array.fill(~length, 0.8)*~gender1_female.asInteger.normalize;
~amps2_female=Array.fill(~length, 0.8)*~gender2_female.asInteger.normalize;
~amps3_female=Array.fill(~length, 0.8)*~gender3_female.asInteger.normalize;

~amp_male=Array.fill(~length, 1)*~gender1_male.asInteger.normalize;

~amps2_male=Array.fill(~length, 1)*~gender2_male.asInteger.normalize;
~amps3_male=Array.fill(~length, 1)*~gender3_male.asInteger.normalize;
~amps4_male=Array.fill(~length, 1)*~gender4_male.asInteger.normalize;
~amps5_male=Array.fill(~length, 1)*~gender5_male.asInteger.normalize;
~amps6_male=Array.fill(~length, 1)*~gender7_male.asInteger.normalize;
~amps7_male=Array.fill(~length, 1)*~gender8_male.asInteger.normalize;
~amps8_male=Array.fill(~length, 1)*~gender9_male.asInteger.normalize;
~amps10_male=Array.fill(~length, 1)*~gender10_male.asInteger.normalize;




// amplitude multiplication of second ... 17th voices should be lower

// SET DURATION!
// IMPORTANT
// this defines how fast it goes since it sets the length of each sound
~min_dur=0.10;
~max_dur=0.25;
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
	var gender1_female,
    gender1_male, gender2_female,gender3_female, gender2_male,gender3_male,gender4_male,gender5_male,gender6_male,gender7_male,gender8_male,gender9_male,gender10_male;

	gender1_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~cont_freqs1_female), // use trace to print out the current values
	\amp, Pseq(~amps1_female)
);

	gender2_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~cont_freqs2_female),
	\amp, Pseq(~amps2_female) // amps of second voice should be lower
);

	gender3_female = Pbind(
	\instrument, \female,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~cont_freqs3_female),
	\amp, Pseq(~amps3_female) // amps of second voice should be lower
);

	gender1_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~cont_freqs1_male),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amp_male)
);

	gender2_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~cont_freqs2_male*0.90),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amp_male)
);

	gender3_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~cont_freqs3_male*0.80),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amp_male)
);

	gender4_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~cont_freqs4_male*0.7),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amp_male)
);

	gender5_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~cont_freqs5_male*0.6),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amp_male)
);


	gender6_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~cont_freqs6_male*0.5),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amp_male)
);

	gender7_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~cont_freqs7_male*0.4),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amp_male)
);

	gender8_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~cont_freqs8_male*0.3),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amp_male)
);

	gender8_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~cont_freqs8_male*0.25),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amp_male)
);

	gender9_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~cont_freqs9_male*0.15),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amp_male)
);

	gender10_male = Pbind(
	\instrument, \mymalesynth,
	\dur, Pwhite(~min_dur, ~max_dur, ~length),
	\hz, Pseq(~cont_freqs10_male*0.1),
	\atk, Pwhite(~min_attack_male, ~max_attack_male, ~length),
	\rel, Pwhite(~min_release_male, ~max_release_male, ~length),
	\amp, Pseq(~amp_male)
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


