clear('all');

sampling_rate = 44100;
notes_cell = {'A2.wav' 'A#2.wav' 'B2.wav' 'C3.wav' 'C#3.wav' 'D3.wav' 'D#3.wav' 'E3.wav' 'F3.wav' 'F#3.wav' 'G3.wav' 'G#3.wav'};
notes_cell = fliplr(notes_cell);

bases_piano = {};
for note = 1:length(notes_cell)
	signal_piano = wavread(horzcat('notes_piano/',notes_cell{note}));
	signal_piano = signal_piano(:,1);
	signal_piano = signal_piano(1:2*sampling_rate);
	bases_piano{note} = signal_piano./max(signal_piano);
end

bases_guitar = {};
for note = 1:length(notes_cell)
	signal_guitar = wavread(horzcat('notes_guitar/',notes_cell{note}));
	signal_guitar = signal_guitar(:,1);
	signal_guitar = signal_guitar(1:2*sampling_rate);
	bases_guitar{note} = signal_guitar./max(signal_guitar);
end

% open the music to verify
signal = wavread('music_piano_guitar_3.wav');
downsample_rate = 2;
signal = signal(:,1);

% cut the music in parts or windows
signals = {};
window_size = 0.128;
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

%figure; surf(energy_notes_time_guitar);

% build chromagram with 12 chromas
chromagram(12, total_time) = 0;
for time = 1:total_time
	for note = 1:12
		chromagram(note, time) = energy_notes_time_guitar(note, time);% + energy_notes_time_guitar(note + 12, time);
	end
	for note = 1:12
		if chromagram(note, time) == max(chromagram(:, time))
			chromagram(note, time) = max(chromagram(:, time));
		else
			chromagram(note, time) = 0;
		end
	end
end

% invert chromagram to plot
chromagram_inverse_notes(size(chromagram)) = 0;
for note = 1:12
	chromagram_inverse_notes(12 + 1 - note, :) = chromagram(note, :);
end
chromagram_guitar = chromagram;
%chromagram_guitar = chromagram_inverse_notes;
figure;
%chromagram_inverse_notes = chromagram_inverse_notes(1:end, 1:end-3);
imagesc([0:0.128:12],[1:12], chromagram_guitar);
title('Chromagram With CCM - Acoustic Guitar')
set(gca,'YTickLabel',{' ' ' ' ' '  ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '});

[rows, columns] = find(chromagram_guitar);
row_not_repeated = [];
number_row_not_repeated = 1;
for number_row = 1:length(rows)-1
	if rows(number_row) ~= rows(number_row + 1)
		row_not_repeated(number_row_not_repeated) = rows(number_row);
		number_row_not_repeated = number_row_not_repeated + 1;
	end
end
rows = row_not_repeated(1:12);

 ideal_sequence = [1 3 5 3 1 3 5 3 1 3 5 3];
ideal_sequence = [12:-1:1];
result = corrcoef(rows, ideal_sequence);
percentual_hits_guitar = result(1,2)*100




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

%figure; surf(energy_notes_time_piano);

% build chromagram with 12 chromas
chromagram(12, total_time) = 0;
for time = 1:total_time
	for note = 1:12
		chromagram(note, time) = energy_notes_time_piano(note, time);% + energy_notes_time_piano(note + 12, time);
		for note = 1:12
			if chromagram(note, time) == max(chromagram(:, time))
				chromagram(note, time) = max(chromagram(:, time));
			else
				chromagram(note, time) = 0;
			end
		end
	end
end

% invert chromagram to plot
chromagram_inverse_notes(size(chromagram)) = 0;
for note = 1:12
	chromagram_inverse_notes(12 + 1 - note, :) = chromagram(note, :);
end
chromagram_piano = chromagram;
%chromagram_piano = chromagram_inverse_notes;
figure;
%chromagram_inverse_notes = chromagram_inverse_notes(1:end, 1:end-3);
imagesc([0:0.128:12],[1:12], chromagram_piano);
title('Chromagram With CCM - Piano')
set(gca,'YTickLabel',{' ' ' ' ' '  ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '});

[rows, columns] = find(chromagram_piano);
row_not_repeated = [];
number_row_not_repeated = 1;
for number_row = 1:length(rows)-1
	if rows(number_row) ~= rows(number_row + 1)
		row_not_repeated(number_row_not_repeated) = rows(number_row);
		number_row_not_repeated = number_row_not_repeated + 1;
	end
end
rows = row_not_repeated(1:12);
ideal_sequence = [12:-1:1];
result = corrcoef(rows, ideal_sequence);
percentual_hits_piano = result(1,2)*100