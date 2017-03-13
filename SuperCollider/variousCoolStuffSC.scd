
Server.default=s=Server.internal;   //run this line first

s.boot;

// spectral plotting of the created sounds
FreqScope.new

// subtractive synthesis
{LPF.ar(WhiteNoise.ar(0.1),1000)}.scope
// varying over time
{LPF.ar(WhiteNoise.ar(0.1),Line.kr(10000,1000,10))}.scope
// take ten seconds to go from 10000 to 1000: inputs to Line are start, end, duration

{Resonz.ar(LFNoise0.ar(400),Line.kr(10000,1000,3),0.1)}.scope

// neater way of doing the above
(
{
var source, line, filter; 	//local variables to hold objects

source=LFNoise0.ar(500);
line=Line.kr(990,0,4);
filter=Resonz.ar(source,line,0.1);
//the filtered output is the input source filtered by Resonz with a line control for the resonant frequency

filter // last thing is returned from function in curly brackets, i.e. this is the final sound we hear
}.scope;
)


// multiple sinusoids

{SinOsc.ar([400,660],0,0.1)}.scope

// panning
{Pan2.ar(WhiteNoise.ar(0.1), MouseX.kr(-1,1))}.scope


{Pan2.ar(Mix(SinOsc.ar([400,660],0,0.1)),MouseX.kr(-1,1))}.scope



x = CSVFileReader.readInterpret("CSVReadTestNum.sc", true, true).postln;

