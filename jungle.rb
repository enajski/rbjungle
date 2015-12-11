require "~/experiments/rbjungle/methods.rb"
require "~/experiments/rbjungle/sounds.rb"
require "~/experiments/rbjungle/effects.rb"
require "marky_markov"

intro = [:puci, :puci, :puci, :puci, :taci, :taci, :taci, :ciu]
main1 = [:cii,  :cii,  :taci, :taci, :cii,  :cii , :cii,  :cii]
solo1 = main1.shuffle[0..-2] + [:ciu]
verse1 = [:puci, :taci, :puci, :taci, :taci, :taci, :puci, :ciu]
hard_verse1 = [:puci, :stab, :puci, :puci, :stab, :stab, :taci, :stab, :taci, :stab, :cii, :cii, :stab, :ciu]

def references(amp: 0.5, rate: 1.0)
  with_fx :echo, phase: 0.15, mix: 0.6 do
    with_fx :hpf, cutoff: 40 do
      with_fx :wobble, amp: amp, cutoff_min: 60, cutoff_max: 128, filter: 0 do
        [lambda { sample :bass_voxy_c, amp: rrand(0.1, 0.4), rate: rate },
         lambda { sample :ambi_piano, amp: rrand(0.3, 0.7), rate: rate },
         lambda { sample :guit_harmonics, amp: amp}].choose.call
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

  use_synth :sine
  use_random_seed rrand(0, 50000)

  bass_seq = make_fixed_length_seq(length: 8.0 * 0.3, timings: [0.3, 0.6, 0.15]) do
    chord([[:c2, :m7], [:d2, :m7]].sample).sample
  end

  4.times do

    distort do
      with_fx :rlpf, cutoff: rrand(70, 130), res: [0.1, 0.2].choose do
        random_pan do

          bass_seq.each do |timed_note|
            play timed_note.keys.first, release: [0.6, 0.3, 0.15].select { |n| n <= timed_note.values.first }.choose, amp: rrand(0.8, 1.0)
            sleep timed_note.values.last
          end

        end
      end
    end
  end
end

define :samplepack do
  4.times { references amp: 0.8, rate: 1.0 }
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
