require "~/experiments/rbjungle/methods.rb"
require "~/experiments/rbjungle/sounds.rb"
require "~/experiments/rbjungle/effects.rb"
require "marky_markov"

intro = [:puci, :puci, :puci, :puci, :taci, :taci, :taci, :ciu]
main1 = [:cii,  :cii,  :taci, :taci, :cii,  :cii , :cii,  :cii]
solo1 = main1.shuffle[0..-2] + [:ciu]
verse1 = [:puci, :taci, :puci, :taci, :taci, :taci, :puci, :ciu]
hard_verse1 = [:puci, :stab, :puci, :puci, :stab, :stab, :taci, :stab, :taci, :stab, :cii, :cii, :stab, :ciu]

def riff(prophet_ctl: 0, tb303_ctl: 0, noise_ctl: 0, square_ctl: 0)
  with_fx :echo, phase: 0.15, mix: 0.6 do
    puts "#{prophet_ctl} #{tb303_ctl}, #{noise_ctl}, #{square_ctl}"

    [[:c3, :m7], [:c4, :m7]].each do |tonation|
      4.times do
        use_synth synth_mix(prophet: prophet_ctl, tb303: tb303_ctl, noise: noise_ctl, square: square_ctl).choose
        play choose(chord(tonation)), release: [0.1, 0.2, 0.3].choose, amp: rrand(0.2, 1.0)
        sleep map_durations(conservative: 3, wild: 1).choose
      end
    end
  end
end

def synth_mix(prophet: 0, tb303: 0, noise: 0, square: 0)
  ([:supersaw] * prophet) + ([:tb303] * tb303) + ([:pnoise] * noise) + ([:square] * square)
end

def references(amp: 0.5, rate: 1.0)
  with_fx :echo, phase: 0.15, mix: 0.6 do
    with_fx :hpf, cutoff: 40 do
      with_fx :wobble, amp: amp, cutoff_min: 60, cutoff_max: 128, filter: 0 do
        [lambda { sample :bass_voxy_c, amp: rrand(0.1, 0.4), rate: rate },
         lambda { sample :ambi_piano, amp: rrand(0.3, 0.7), rate: rate }].choose.call
      end
    end
    sleep map_durations(conservative: 2, wild: 1, slow: 3).choose
  end
end

define :drums do
  with_fx :reverb, room: 0.2, mix: 0.05 do
    distort do
      [intro, main1, verse1, hard_verse1].each do |part|
        markov = MarkyMarkov::TemporaryDictionary.new
        markov.parse_string(part.join(" "))

        seq_length = [8, 16].sample

        seq = markov.generate_n_words(seq_length).gsub(".", "").split(" ").map(&:to_sym)
        seq[0] = [:puci, :kick].sample

        3.times { verse seq }

        with_fx :ixi_techno, res: 0.4, amp: 0.8 do
          1.times { verse seq }
        end
      end
    end
  end
end

define :bass do
  random_pan do
    with_fx :rlpf, cutoff: rrand(20, 100), res: [0.1, 0.2].choose do
      distort do
        4.times { riff(prophet_ctl: 1, tb303_ctl: 0, noise_ctl: 0, square_ctl: 0) }
      end
    end
    with_fx :rlpf, cutoff: rrand(60, 130), res: [0.1, 0.2].choose do
      distort do
        4.times { riff(tb303_ctl: 1, square_ctl: 0) }
      end
    end
  end
end

define :samplepack do
  references amp: 0.1, rate: 0.1
  references amp: 0.2, rate: 0.2
  references amp: 0.3, rate: 0.5
  references amp: 0.4, rate: 0.8
  4.times { references amp: 0.7, rate: 4.0 }
end

in_thread(name: :looper) do
  loop do
    sleep 32 * 0.3
    drums
  end
end

in_thread(name: :basser) do
  loop do
    bass
  end
end

in_thread(name: :sampler) do
  loop do
    samplepack
    sleep 12
  end
end
