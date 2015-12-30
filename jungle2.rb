require "~/experiments/rbjungle/methods.rb"
require "~/experiments/rbjungle/sounds.rb"
require "~/experiments/rbjungle/effects.rb"
require "marky_markov"

BREAK_PATHS = Dir.chdir("/Users/dev/Music/real_jungle_loops_by_noise_relations/") do
  Dir.glob("*.wav").map { |path| Dir.pwd + "/" + path }
end

LOOP_LENGTH = 1.4
NOTE_LENGTH_DISTRIBUTION = [(LOOP_LENGTH / 2), (LOOP_LENGTH / 4), (LOOP_LENGTH / 8)]

def timing_to_sleep(timing:, loop_length_in_seconds:)
  start = timing.first
  finish = timing.last

  partial_length = finish - start
  partial_length * loop_length_in_seconds
end

def play_break_seq(drum_seq:, break_path:)
  drum_seq.each do |timed_note|
    normal_speed_to_slowdown_distribution = ([1.0] * 15) + [0.5]

    sample break_path, start: timed_note.first, finish: timed_note.last, rate: normal_speed_to_slowdown_distribution.sample
    sleep timing_to_sleep(timing: timed_note, loop_length_in_seconds: LOOP_LENGTH)
  end
end

in_thread(name: :breakz) do
  loop do
    with_fx :reverb, room: 0.2, mix: 0.05 do
      distort do

        main_break = BREAK_PATHS.sample
        fill_in_break = BREAK_PATHS.sample

        puts main_break
        puts fill_in_break

        timings = [[0.0, 0.25], [0.25, 0.5], [0.5, 0.75], [0.75, 1.0]]

        first_drum_seq = [timings.first] + 7.times.collect { timings.sample }

        2.times do

          3.times do
            play_break_seq(drum_seq: first_drum_seq, break_path: main_break)
          end

          fill_in_drum_seq = [timings.first] + 7.times.collect { timings.sample }

          1.times do
            play_break_seq(drum_seq: fill_in_drum_seq, break_path: fill_in_break)
          end

        end
      end
    end
  end
end

in_thread(name: :bass) do
  loop do
    use_synth %w(sine).sample

    bass_seq = make_fixed_length_seq(length: 16.0 * (LOOP_LENGTH / 4.0), timings: NOTE_LENGTH_DISTRIBUTION) do
      chord([[:c2, :m7], [:d2, :m7]].sample).sample
    end

    4.times do |index|

      bass_seq.shuffle! if index == 3

      distort do
        with_fx :rlpf, cutoff: rrand(70, 130), res: [0.2, 0.4].choose do
          random_pan do

            bass_seq.each do |timed_note|
              play timed_note.keys.first, release: NOTE_LENGTH_DISTRIBUTION.select { |n| n <= timed_note.values.first }.choose, amp: rrand(0.6, 0.8)
              sleep timed_note.values.last
            end

          end
        end
      end
    end
  end
end

in_thread(name: :sounds) do
  loop do
    with_fx :echo, phase: 0.6, mix: 0.6 do
      with_fx :hpf, cutoff: 40 do
        with_fx :wobble, amp: 0.5, cutoff_min: 60, cutoff_max: 128, filter: 0 do
          [lambda { sample :bass_voxy_c, amp: rrand(0.1, 0.4), rate: 1.0 },
           lambda { sample :ambi_piano, amp: rrand(0.3, 0.7), rate: 1.0 },
           lambda { sample :guit_harmonics, amp: 0.5}].choose.call
        end
      end
      sleep map_durations(conservative: 2, wild: 1, slow: 3).choose
    end
  end
end