def taci
  sample :loop_amen, start: 0.75, finish: 1, rate: 1.5
end

def cita
  sample :loop_amen, start: 0.5, finish: 0.75, rate: 1.5
end

def puci
  sample :loop_amen, start: 0.0, finish: 0.25, rate: 1.5
end

def cii
  sample :loop_amen_full, start: 0.905, finish: 0.96, rate: 1.5, amp: 0.6
end

def ciu
  sample :loop_amen_full, start: 0.905, finish: 0.93, rate: [0.75, 1, 1.25].choose, amp: 0.6
end

intro = [:puci, :puci, :puci, :puci, :taci, :taci, :taci, :ciu]
main1 = [:cii,  :cii,  :taci, :taci, :cii,  :cii , :cii,  :cii]
solo1 = main1.shuffle[0..-2] + [:ciu]

def riff
  with_fx :echo, phase: [0.3, 0.6, 1.2].choose, mix: 0.2 do
    use_synth synth_mix(prophet: 0, tb303: 1, noise: 0, square: 0).choose
    play choose(chord(:c2, :minor)), release: [0.1, 0.2, 0.3].choose, amp: rrand(0.2, 2)
    sleep map_durations(conservative: 3, wild: 1).choose
  end
end

def synth_mix(prophet: 1, tb303: 2, noise: 1, square: 5)
  ([:supersaw] * prophet) + ([:tb303] * tb303) + ([:pnoise] * noise) + ([:square] * square)
end

define :drums do
  with_fx :reverb, room: 0.2, mix: 0.05 do
    distort do
      2.times { verse intro }
      verse main1
      with_fx :ixi_techno, res: 0.4, amp: 0.8 do
        verse solo1
      end
    end
  end
end

define :bass do
  random_pan do
    with_fx :rlpf, cutoff: rrand(50, 130), res: [0.1, 0.2].choose do
      distort do
        3.times { riff }
      end
    end
  end
end

def distort(&block)
  with_fx :distortion, distort: 0.8 do
    yield
  end
end

def random_pan(&block)
  with_fx :pan, pan: [-0.1, 0, 0.1].choose do
    yield
  end
end

def verse(sequence)
  sequence.map { |note| word note }
end

def word(note)
  self.send(note)
  self.send([:faster, :slower].choose)
end

def faster
  sleep map_durations(conservative: 6, wild: 3, slow: 0).choose
end

def slower
  sleep map_durations(conservative: 6, wild: 1, slow: 1).choose
end

def map_durations(conservative: 7, wild: 1, slow: 1)
  ([0.15] * wild) + ([0.3] * conservative) + ([0.45] * slow)
end

in_thread(name: :looper) do
  loop do
    drums
  end
end

in_thread(name: :basser) do
  loop do
    bass
  end
end