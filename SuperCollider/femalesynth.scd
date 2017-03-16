(
play {
    Limiter.ar(
        tanh(
            3 * GVerb.ar(
                HPF.ar(
                    PinkNoise.ar(0.08+LFNoise1.kr(0.3,0.02))+LPF.ar(Dust2.ar(LFNoise1.kr(0.2).range(40,50)),7000),
                    400
                ),
                250,100,0.25,drylevel:0.3
            ) * Line.kr(0,1,10)
        ) + (
            GVerb.ar(
                LPF.ar(
                    10 * HPF.ar(PinkNoise.ar(LFNoise1.kr(3).clip(0,1)*LFNoise1.kr(2).clip(0,1) ** 1.8), 20)
                    ,LFNoise1.kr(1).exprange(100,2500)
                ).tanh,
               270,30,0.7,drylevel:0.5
            ) * Line.kr(0,0.7,30)
        )
    )
};
)




play{Splay.ar(Ringz.ar(Decay2.ar(Impulse.ar([2,3]),0.0001,0.01),Array.geom(9,40,1.75)*LFDNoise3.ar(6,0.1),0.9,0.1))} // #supercollider #sc

play{Ringz.ar(Decay2.ar(TDuty.ar(Dseq([1,1,2,1,1,2,1,4]/10,inf)),0,0.001),Array.geom(12,50,1.1)*LFNoise2.kr(0.5,0.02,1),1,0.01).sum!2}// #sc


play{RLPF.ar(Latch.ar(SinOsc.ar([100,100.5])!2,Impulse.ar(Duty.kr(Dseq([2,1]/4,inf),0,Drand((67,67.2..70),inf)))),800)} // #sc _dubsteppy_

play{x=LFNoise2.kr(22,5,9);CombC.ar(Splay.ar(Gendy3.ar([4,2],[0.5,1],[1/9,1/4]*x,[1/2,1/8]*x,(9,49..199))),5,[0.13,0.1],[x/2,x/2.1])} // #sc


play{GVerb.ar(Decay2.ar(TDuty.ar(Dwrand([2,4,8,16]/16,[7,1,1,1]/10,inf)),0.02,0.05,SinOsc.ar(LFDNoise3.kr(40,199,150))).tanh,1,0.5)} // #sc

play{d=Duty;f=d.kr(1/[1,2,4],0,Dseq([0,3,7,12,17]+24,inf));GVerb.ar(Blip.ar(f.midicps*[1,4,8],LFNoise1.kr(1/4,3,4)).sum,200,8)}



(
{
Mix.fill(10,{
var freq;

freq= rrand(130,160.3);
Pan2.ar(SinOsc.ar(Gendy2.ar(6.rand,6.rand,SinOsc.kr(0.1,0,0.49,0.51),SinOsc.kr(0.13,0,0.49,0.51),freq ,freq, SinOsc.kr(0.17,0,0.49,0.51), SinOsc.kr(0.19,0,0.49,0.51), 12, 12, 0.4.rand, 0.4.rand, 200, 400), 0, 0.1), 1.0.rand2)
});
}.play
)


(
SynthDef(\female, {arg roomsize, revtime, damping, inputbw, spread = 15, drylevel, earlylevel,
	        taillevel, freq=1760;
    var a = Resonz.ar(
		// arguments: input signal, resonant frequency in Hz, bandwidth ratio, output mul, output add
		// Dust : arg density (average number of impulses per second)
        Array.fill(4, {Impulse.ar(0)}), freq  * [1, 2, 4, 8], 0.01).sum*10;

//    var a = SoundIn.ar(0);
//    var a = PlayBuf.ar(1, 0);
    Out.ar(0, GVerb.ar(
        a,
        roomsize,
        revtime,
        damping,
        inputbw,
        spread,
        drylevel.dbamp,
        earlylevel.dbamp,
        taillevel.dbamp,
        roomsize, 0.3) + a)}).add
)

s.boot;
s.scope(2);


// bathroom
a = Synth(\test, [\freq , 1700, \roomsize, 5, \revtime, 0.6, \damping, 0.62, \inputbw, 0.48, \drylevel -6, \earlylevel, -11, \taillevel, -13]);
a.free;

//living room
a = Synth(\test, [\roomsize, 16, \revtime, 1.24, \damping, 0.10, \inputbw, 0.95, \drylevel -3, \earlylevel, -15, \taillevel, -17]);
a.free;

//church
a = Synth(\test, [\roomsize, 80, \revtime, 4.85, \damping, 0.41, \inputbw, 0.19, \drylevel -3, \earlylevel, -9, \taillevel, -11]);
a.free;

// cathedral
a = Synth(\test, [\roomsize, 243, \revtime, 1, \damping, 0.1, \inputbw, 0.34, \drylevel -3, \earlylevel, -11, \taillevel, -9]);
a.free

// canyon
a = Synth(\test, [\roomsize, 300, \revtime, 103, \damping, 0.43, \inputbw, 0.51, \drylevel -5, \earlylevel, -26, \taillevel, -20]);
a.free;

s.quit;


// PERCUSSION

(
x = {
	var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res;

	locutoffenv = EnvGen.ar(Env.perc(0.25, 5)) * 1000 + 10;
	lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);

	hicutoffenv = 10001 - (EnvGen.ar(Env.perc(1, 3)) * 1000);
	hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv);
	hidriver = hidriver * EnvGen.ar(Env.perc(1, 2, 0.25));

	freqs  = {exprand(300, 20000)}.dup(100);
	res    = Ringz.ar(lodriver + hidriver, freqs).mean.dup
}.play;
)

