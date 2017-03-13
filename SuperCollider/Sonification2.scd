

s.boot()



// READ LIST
~text = CSVFileReader.read("/Users/emmafrid/kurser/creative_coding/women-in-smc/genderOutputFinal3.csv", true).postcs;
~text=~text.flop;
~gender1=~text[1] // gender column;
~gender2=~text[2].drop(1);
~gender3=~text[3].drop(1);
~gender4=~text[4].drop(1);
~gender5=~text[5].drop(1);
~gender6=~text[6].drop(1);

// gender encoding:
// 0 : unknown, 1 : male, 2 : mostly male, 3 : mostly female, 4 : female

/// SYNTH DEFINITIONS
(
 SynthDef(\mysynth, {|out = 0, freq, amp, dur, pan = 0, mod = 50|
  var pm, modulator, env, panner;

  modulator = SinOsc.ar(mod, 0, 0.2);
  pm = SinOsc.ar(freq, modulator);

  env = EnvGen.kr(Env.perc(0.01, dur, amp), doneAction:2);
  panner = Pan2.ar(pm, pan, env);

  Out.ar(out, panner);
 }).store
)

(
 SynthDef(\mymalesynth, {|out = 0, freq, amp, dur, pan = 0, mod = 50|
  var pm, modulator, env, panner;

  modulator = PinkNoise.ar(mod, 0, 0.1);
  //pm = SinOsc.ar(freq, modulator);
 pm = { Klank.ar(`[ {exprand(freq*5, freq*100)}.dup(12), nil, nil ], PinkNoise.ar(0.009)) };

  env = EnvGen.kr(Env.perc(0.1, dur, amp), doneAction:2);
  panner = Pan2.ar(pm, pan, env);

  Out.ar(out, panner);
 }).store
)

(
SynthDef.new(\sine, {
	arg hz=440, atk=0.005, rel=0.3, amp=1, pan=0;
	var sig, env;
	sig = SinOsc.ar(hz);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)


// FIRST GENDER COLUMN
n=size(~gender1)
// plot(~gender1.asInteger)


~length=n
~durs=Array.fill(~length, 0.2); // should be n but set to lower for testing
~freqfact=450 // 800 for continuous

// ALL FREQUENCIES
(
~freqs1 = ~gender1.asInteger.normalize * ~freqfact;
~freqs2 = ~gender2.asInteger.normalize * ~freqfact;
~freqs3 = ~gender3.asInteger.normalize * ~freqfact;
~freqs4 = ~gender4.asInteger.normalize * ~freqfact;
~freqs5 = ~gender5.asInteger.normalize * ~freqfact;
~freqs6 = ~gender6.asInteger.normalize * ~freqfact;
)

// ALL AMPS
(
~amps1=Array.fill(~length, 2)*~gender1.asInteger.normalize;
~amps2=Array.fill(~length, 1)*~gender2.asInteger.normalize;
~amps3=Array.fill(~length, 1)*~gender3.asInteger.normalize;
~amps4=Array.fill(~length, 1)*~gender4.asInteger.normalize;
~amps5=Array.fill(~length, 1)*~gender5.asInteger.normalize;
~amps6=Array.fill(~length, 1)*~gender6.asInteger.normalize;
)



////// CONTINUOUS SONIFICATION

s.boot
s.plotTree
(
~contfreq1= Array.fill(~length, {exprand(1.0, 1.3)})*~freqs1.postln;
~contfreq2= Array.fill(~length, {exprand(1.0, 1.3)})*~freqs2.postln;
~contfreq3= Array.fill(~length, {exprand(1.0, 1.3)})*~freqs3.postln;
~contfreq4= Array.fill(~length, {exprand(1.0, 1.3)})*~freqs4.postln;
~contfreq5= Array.fill(~length, {exprand(1.0, 1.3)})*~freqs5.postln;
~contfreq6= Array.fill(~length, {exprand(1.0, 1.3)})*~freqs6.postln;
)


// create array of random numbers

(
	var gender1, gender2, gender3, gender4, gender5, gender6;

	gender1 = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.2, 0.3, ~length),
	\hz, Pseq(~contfreq1).trace,
	\atk, Pwhite(0.5, 0.8, ~length),
	\rel, Pwhite(1.0, 1.5, ~length),
	\amp, Pseq(~amps1*0.5)
);

	gender2 = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.2, 0.3, ~length),
	\hz, Pseq(~contfreq2),
	\atk, Pwhite(0.5, 0.8, ~length),
	\rel, Pwhite(1.0, 1.5, ~length),
	\amp, Pseq(~amps2*0.5)
);

gender3 = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.2, 0.3, ~length),
	\hz, Pseq(~contfreq3),
	\atk, Pwhite(0.5, 0.8, ~length),
	\rel, Pwhite(1.0, 1.5, ~length),
	\amp, Pseq(~amps3*0.5)
);

gender4 = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.2, 0.3, ~length),
	\hz, Pseq(~contfreq4),
	\atk, Pwhite(0.5, 0.8, ~length),
	\rel, Pwhite(1.0, 1.5, ~length),
	\amp, Pseq(~amps4*0.5)
);

gender5 = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.2, 0.3, ~length),
	\hz, Pseq(~contfreq5),
	\atk, Pwhite(0.5, 0.8, ~length),
	\rel, Pwhite(1.0, 1.5, ~length),
	\amp, Pseq(~amps5*0.5)
);

gender6 = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.2, 0.3, ~length),
	\hz, Pseq(~contfreq6),
	\atk, Pwhite(0.5, 0.8, ~length),
	\rel, Pwhite(1.0, 1.5, ~length),
	\amp, Pseq(~amps6*0.5)
);


 Ptpar([ 0.0, gender1, 0.5, gender2,0.6, gender3,0.7, gender4,0.8, gender5,0.9, gender6], 1).play; // use Ptpar to change wait between trigger of different voices

)






///////// DISCRETE SONIFICATION

(
	var gender1, gender2, gender3, gender4, gender5, gender6;

	gender1 = Pbind(
	\instrument, \mymalesynth,
	\freq,  Pseq( ~freqs1, inf).trace,
	\dur,  Pwhite(0.8, 0.9, ~length),
	\amp, Pseq(~amps1)
);

	gender2 = Pbind(
	\instrument, \mysynth,
	\freq,  Pseq( ~freqs2 , inf),
	\dur,  Pwhite(0.2, 0.4, ~length),
	\amp, Pseq(~amps2)
 );

gender3 = Pbind(
	\instrument, \mysynth,
	\freq,  Pseq( ~freqs3 , inf),
	\dur,  Pwhite(0.2, 0.4, ~length),
	\amp, Pseq(~amps3)
 );

gender4 = Pbind(
	\instrument, \mysynth,
	\freq,  Pseq( ~freqs4 , inf),
	\dur,  Pwhite(0.2, 0.4, ~length),
	\amp, Pseq(~amps4)
 );

gender5 = Pbind(
	\instrument, \mysynth,
	\freq,  Pseq( ~freqs5 , inf),
	\dur,  Pwhite(0.2, 0.4, ~length),
	\amp, Pseq(~amps5)
 );

gender6 = Pbind(
	\instrument, \mysynth,
	\freq,  Pseq( ~freqs6 , inf),
	\dur,  Pwhite(0.2, 0.4, ~length),
	\amp, Pseq(~amps6)
 );

 Ptpar([ 0.0, gender1, 0.5, gender2,0.6, gender3,0.7, gender4,0.8, gender5,0.9, gender6], 1).play; // use Ptpar to change wait between trigger of different voices

)
