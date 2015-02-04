def verse(sequence)
  sequence.map { |note| word note }
end

def word(note)
  self.send(note)
  self.send(:faster)
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
