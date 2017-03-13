
s.boot()

// DEFINE SYNTH
// add latency to your outgoing Synths is with the Server using makeBundle
SynthDef(\SimpleSine, { arg freq = 440; Out.ar(0, SinOsc.ar(freq, 0, 0.2)) }).send(s);



// DYNAMIC KLANG SO AS TO CHANGE FREQ CONTINUOUSLY
(
SynthDef(\reson, {arg amp=0.4, dur=1, pan=0.0, t_trig, freqfact=1;
	var  env, signal, frequencies;
	env = EnvGen.ar(Env.perc(0.01, dur, amp), t_trig, doneAction:0);  // doneAction 0 keeps the synth on the server after triggering it
	frequencies =  {exprand(100, 1000)}.dup(8)*freqfact;
	signal = DynKlang.ar(`[frequencies, nil, nil ], 1, 0) * 0.05* env; //bank of resonators
	signal = Pan2.ar(signal, pan);
	Out.ar(0, signal);
}).add;
)



// ONE SYNTH PER AUTHOR GROUP (1st author/2nd author....6th author)
//w = Synth(\SimpleSine);
w = Synth(\reson, [\amp, 1, \t_trig, 1])
//w.set(\freqfact, 1.5,\t_trig, 1);

// READ LIST
~text = CSVFileReader.read("/Users/emmafrid/kurser/creative_coding/women-in-smc/genderOutput2.csv", true).postcs;
~text=~text.flop;
~gender1=~text[1] // gender column
~authors=~text[4]

(	// create multichannel controls directly with literal arrays:
SynthDef('noise', {| freqs (#[100, 200, 300, 400]),
	amps (#[1, 0.3, 0.2, 0.05]),
	rings (#[1, 1, 1, 2])|
	var signal = DynKlank.ar(`[freqs, amps, rings], WhiteNoise.ar * 0.001);
	Out.ar(0,signal)
}).send(s)
)

b = Synth('noise');
b.setn(\freqs, Array.rand(4, 200, 500));
b.free

// why are there empty rows?

r = Routine.new ({
	size(~gender1).do({ arg index;
		index.postln;
		~gender1[index].postln;

		// it should actually be multiple synthesizers
		w.set(\freqfact, switch(
			~gender1[index],
			"male", {1.0},
			"female", {2.0},
			"mostly_male", {1.0},
			"mostly_female", {2.0},
			"unknown", {1.0}
		));

		w.set(\t_trig, 1);
		1.wait; // wait one second
	});
});


p = Routine.new ({
	size(~gender1).do({ arg index;
		index.postln;
		~gender1[index].postln;

		// it should actually be multiple synthesizers
		b.set(\freqs, switch(
			~gender1[index],
			"male", {Array.rand(4, 200, 1000)},
			"female", {Array.rand(4, 0.1, 200)},
			"mostly_male", {Array.rand(4, 200, 1000)},
			"mostly_female", {Array.rand(4, 100, 1000)},
			"unknown", {Array.rand(4, 200, 1000)}
		));

		3.wait; // wait one second
	});
});
// START AND STOP ROUTINE
// CONSIDER USING STREAMS INSTEAD
p.play
p.stop

r.play
r.stop

// FREE SYNTH
b.free





