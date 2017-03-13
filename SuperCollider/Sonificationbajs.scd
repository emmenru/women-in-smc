
s.boot

// read a file containing bibtex entries
x = CSVFileReader.read("/Users/emmafrid/kurser/creative_coding/women-in-smc/genderOutput2.csv", true).postcs; // remove empty lines and close

x[1][0] // prints first line entry (row,column) // name column
size(x) // number of rows, i.e. articles
// x.class


// fixing columns
y=x.flop;
n=y[0] // name column
g=y[1] // gender column
c=y[2] // country column



// go through values from 1 to length of vector and print gender
// skip first entry in array (title of column)







(
SynthDef(\singrain, { |freq = 300, amp = 0.2, sustain = 1|
    var sig;
    sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.perc(0.01, sustain), doneAction: 2);
    Out.ar(0, sig ! 2);    // sig ! 2 is the same as [sig, sig]
}).add;


r = Routine.new ({
	var delta;
	size(g).do({ arg index;
		index.postln;
		g[index].postln;
		delta = rrand(1, 3) * 0.5;
        Synth(\singrain, [freq: 440, amp: 0.2, sustain: delta * 0.8]);
        delta.yield;
		1.wait; // wait one second
});
});


)

s.scope;
r.play;
r.stop;