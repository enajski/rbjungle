def verse(sequence)
  sequence.map do |note|
    self.send(note)
    sleep 0.3
  end
  puts "Ended #{sequence.size} note bar"
end

def word(note)
  self.send(note)
  self.send(playing_styles.sample)
end

def playing_styles
  [:faster, :slower]
end

def faster
  sleep map_durations(conservative: 6, wild: 4, slow: 0).choose
end

def slower
  sleep map_durations(conservative: 6, wild: 2, slow: 1).choose
end

def map_durations(conservative: 8, wild: 0, slow: 0)
  ([0.15] * wild) + ([0.3] * conservative) + ([0.45] * slow)
end

def make_fixed_length_seq(length:, timings:, &block)
  seq = []
  current_length = 0.0

  while seq.empty? || current_length < length
    new_note = yield
    new_timing = timings.sample

    new_timed_note = {new_note => new_timing}

    if seq.empty? || (length - current_length).round(3) >= new_timing
      seq.push(new_timed_note)
      current_length = (current_length + new_timing).round(3)
    end
  end

  seq
end