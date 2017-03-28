def verse(sequence)
  sequence.map do |note|
    self.send(note)
    sleep 0.3
  end
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

def make_markov(input)
  markov = MarkyMarkov::TemporaryDictionary.new
  markov.parse_string(input.join(" "))

  seq_length = [8, 16].sample

  markov.
    generate_n_words(seq_length).
    gsub(".", "").
    split(" ").
    map(&:to_sym)
end

def timing_to_sleep(timing:, loop_length_in_seconds:)
  start = timing.first
  finish = timing.last

  partial_length = finish - start
  partial_length * loop_length_in_seconds * 1.0
end

def play_break_seq(drum_seq:, break_path:, length:, overlap: 0.0)
  density length / LOOP_LENGTH do
    drum_seq.each_with_index do |timed_note, index|
      one_sixteenth = ([1.0] * 15) + [0.5]
      normal_speed_to_slowdown_distribution = one_sixteenth

      tempo_adjusted_rate = normal_speed_to_slowdown_distribution.sample

      triggered_break = break_path.is_a?(Array) ? break_path.sample : break_path

      # sample triggered_break, start: timed_note.first, finish: timed_note.last, rate: tempo_adjusted_rate
      sample triggered_break, start: timed_note.first, finish: (timed_note.last + overlap * LOOP_LENGTH), rate: tempo_adjusted_rate
      # sample triggered_break, start: timed_note.first, finish: (timed_note.last + (timed_note.last * (length / LOOP_LENGTH)), rate: tempo_adjusted_rate
      sleep timing_to_sleep(timing: timed_note, loop_length_in_seconds: length)
    end
  end
end