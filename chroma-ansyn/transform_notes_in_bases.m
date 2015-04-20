clear('all');

sampling_rate = 44100;
notes_cell = {'G#4.wav' 'G4.wav' 'F#4.wav' 'F4.wav' 'E4.wav' 'D#4.wav' 'D4.wav' 'C#4.wav' ...
 'C4.wav' 'B3.wav' ...
 'A#3.wav' 'A3.wav' 'G#3.wav' 'G3.wav' 'F#3.wav' 'F3.wav' 'E3.wav' 'D#3.wav' 'D3.wav' ...
  'C#3.wav' 'C3.wav' 'B2.wav' 'A#2.wav' 'A2.wav'};
notes_cell = fliplr(notes_cell);

bases_piano = {};
for note = 1:24
	signal_piano = wavread(horzcat('notes_piano/',notes_cell{note}));
	signal_piano = signal_piano(:,1);
	signal_piano = signal_piano(1:2*sampling_rate);
	bases_piano{note} = signal_piano./max(signal_piano);
end

bases_guitar = {};
for note = 1:24
	signal_guitar = wavread(horzcat('notes_guitar/',notes_cell{note}));
	signal_guitar = signal_guitar(:,1);
	signal_guitar = signal_guitar(1:2*sampling_rate);
	bases_guitar{note} = signal_guitar./max(signal_guitar);
end

% open the music to verify
signal = wavread('music_piano_guitar.wav');
downsample_rate = 2;
signal = signal(:,1);

% cut the music in parts or windows
signals = {};
window_size = 0.5;
total_time = fix(length(signal)/(sampling_rate*window_size));
disp(total_time);
for time = 1:total_time
	% calculate the position in the beginning of signal
	time_start = round(1+((time-1)*(sampling_rate*window_size)));
	% calculate the position in the finishing of signal
	time_end = round(time*(sampling_rate*window_size));
	signals{time} = downsample(signal(time_start:time_end), downsample_rate);
end

%-------------------------------------------------------------------------------
% get energy notes from guitar
energy_notes_time(length(notes_cell), total_time) = 0;
for time = 1:total_time
	disp(time);
	energy_notes(length(notes_cell)) = 0;
	
	for note = 1:length(notes_cell)
		base = bases_guitar{note};
		base = downsample(base, downsample_rate);
		energy_notes(note) = sum((conv(base, [signals{time}]).^2));
	end

	energy_notes = energy_notes - min(energy_notes);
	energy_notes = energy_notes./max(energy_notes);

	energy_notes_time(:, time) = energy_notes;
end
energy_notes_time_guitar = energy_notes_time;

% build chromagram with 12 chromas
chromagram(12, total_time) = 0;
for time = 1:total_time
	for note = 1:12
		chromagram(note, time) = energy_notes_time_guitar(note, time) + energy_notes_time_guitar(note + 12, time);
	end
end

% invert chromagram to plot
chromagram_inverse_notes(size(chromagram)) = 0;
for note = 1:12
	chromagram_inverse_notes(12 + 1 - note, :) = chromagram(note, :);
end
chromagram_guitar = chromagram_inverse_notes;
figure;
%chromagram_inverse_notes = chromagram_inverse_notes(1:end, 1:end-3);
imagesc([0:0.128:12],[1:12], chromagram_guitar);
title('Chromagram With Convolution - Harmonics Acoustic Guitar')
set(gca,'YTickLabel',{' ' ' ' ' '  ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '});

%-------------------------------------------------------------------------------
% get energy notes from piano
energy_notes_time(length(notes_cell), total_time) = 0;
for time = 1:total_time
	disp(time);
	energy_notes(length(notes_cell)) = 0;
	
	for note = 1:length(notes_cell)
		base = bases_piano{note};
		base = downsample(base, downsample_rate);
		energy_notes(note) = sum((conv(base, [signals{time}]).^2));
	end

	energy_notes = energy_notes - min(energy_notes);
	energy_notes = energy_notes./max(energy_notes);

	energy_notes_time(:, time) = energy_notes;
end
energy_notes_time_piano = energy_notes_time;

% build chromagram with 12 chromas
chromagram(12, total_time) = 0;
for time = 1:total_time
	for note = 1:12
		chromagram(note, time) = energy_notes_time_piano(note, time) + energy_notes_time_piano(note + 12, time);
	end
end

% invert chromagram to plot
chromagram_inverse_notes(size(chromagram)) = 0;
for note = 1:12
	chromagram_inverse_notes(12 + 1 - note, :) = chromagram(note, :);
end
chromagram_piano = chromagram_inverse_notes;
figure;
%chromagram_inverse_notes = chromagram_inverse_notes(1:end, 1:end-3);
imagesc([0:0.128:12],[1:12], chromagram_piano);
title('Chromagram With Convolution - Harmonics Piano')
set(gca,'YTickLabel',{' ' ' ' ' '  ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '});