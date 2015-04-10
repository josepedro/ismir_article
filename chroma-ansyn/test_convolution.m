clear('all');

freqs = [27.5 29.135 30.868 32.703 34.648 36.708 38.891 41.203 43.654 46.249 48.999 51.913 55 58.270 61.735 ...
		 65.406 69.296 73.416 77.782 82.407 87.307 92.499 97.999 103.83 110 116.54 123.47 ...
		 130.81 138.59 146.83 155.56 164.81 174.61 185 196 207.65 220 233.08 246.94 ...
		 261.63 277.18 293.66 311.13 329.63 349.23 369.99 392 415.30 440 466.16 493.88 ...
		 523.25 554.37 587.33 622.25 659.26 698.46 739.99 783.99 830.61 880 932.33 987.77 ...
		 1046.5 1108.7 1174.7 1244.5 1318.5 1396.9 1480.0 1568.0 1661.2 1760.0 1864.7 1975.5 ...
		 2093.0 2217.5 2349.3 2489.0 2637.0 2793.8 	2960.0 3136.0 3322.4 3520.0 3729.3 3951.1];

[signal, sampling_rate] = wavread('piano-chrom.wav');
downsample_rate = 2;
signal = signal(:,1);

%signal_1 = signal(1:0.5*sampling_rate);
%signal_2 = signal(0.5*sampling_rate:1*sampling_rate);
%signal_3 = signal(1*sampling_rate:1.5*sampling_rate);

%signal_1 = downsample(signal_1, downsample_rate);
%signal_2 = downsample(signal_2, downsample_rate);
%signal_3 = downsample(signal_3, downsample_rate);

%signals = {signal_1, signal_2, signal_3};

signals = {};
window_size = 0.5;
for time = 1:3
	% calculate the position in the beginning of signal
	time_start = round(1+((time-1)*(sampling_rate*window_size)));
	% calculate the position in the finishing of signal
	time_end = round(time*(sampling_rate*window_size));
	signals{time} = downsample(signal(time_start:time_end), downsample_rate);
end


sampleFreq = sampling_rate/downsample_rate;
dt = 1/sampleFreq;
duration = 1;
times = [0:dt:duration];
filters_notes = {};

energy_notes_time(length(freqs), 3) = 0;
for time = 1:3
	disp(time);
	energy_notes(length(freqs)) = 0;
	
	for note = 1:length(freqs)
		energy_notes(length(freqs) - note + 1) = sum((conv(sin(2*pi*freqs(note)*times),[signals{time}]).^2));
	end

	energy_notes_time(:, time) = energy_notes;
end

figure;
imagesc([1:3], [1:96], (energy_notes_time')');

