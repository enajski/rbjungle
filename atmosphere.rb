def song; with_fx :distortion do; with_fx :reverb do
  sample_pattern = /(bass|guit|ambi)/
  samples = all_sample_names.to_a.select { |sn| sample_pattern.match(sn) }.shuffle
  samples.each do |sn|
    sample sn, pan: [-0.8, 0, 0.8].sample, rate: [0.005, 0.01, 0.02, 0.05, 0.1, 0.2].sample
    sleep [0.15, 0.3, 0.6, 1.2, 2.4, 4.8].sample
  end
end;end;end

in_thread(name: :atmosphere) do; loop do
    song
end;end
