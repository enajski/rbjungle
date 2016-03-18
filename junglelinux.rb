require "~/experiments/rbjungle/methods.rb"
require "~/experiments/rbjungle/sounds.rb"
require "~/experiments/rbjungle/effects.rb"
require "marky_markov"

BREAK_PATHS = Dir.chdir("/media/pi/real_jungle_loops_by_noise_relations/") do
  Dir.glob("*.wav").map { |path| Dir.pwd + "/" + path }
end

RAGGA_PATHS = Dir.chdir("/media/pi/ragga_samples/") do
  Dir.glob("*.wav").map { |path| Dir.pwd + "/" + path }
end

TEMPO = 1.0
LOOP_LENGTH = 1.4 * TEMPO

NOTE_LENGTH_DISTRIBUTION = [(2 * LOOP_LENGTH), LOOP_LENGTH, (LOOP_LENGTH / 2), (LOOP_LENGTH / 4), (LOOP_LENGTH / 8)]

LONG_NOTE_LENGTH_DISTRIBUTION = [(4 * LOOP_LENGTH), (2 * LOOP_LENGTH),LOOP_LENGTH]

SHORT_NOTE_LENGTH_DISTRIBUTION = [(LOOP_LENGTH / 2), (LOOP_LENGTH / 4), (LOOP_LENGTH / 8)]

HALF_SPEED_AND_DOUBLE_SPEED = [1.5, 1.0, 0.5]

def timing_to_sleep(timing:, loop_length_in_seconds:)
  start = timing.first
  finish = timing.last

  partial_length = finish - start
  partial_length * loop_length_in_seconds * 1.0
end

def play_break_seq(drum_seq:, break_path:)
  drum_seq.each do |timed_note|
    one_sixteenth = ([1.0] * 15) + [0.5]
    normal_to_trill_distribution = one_sixteenth
    normal_speed_to_slowdown_distribution = one_sixteenth

    tempo_adjusted_rate = normal_speed_to_slowdown_distribution.sample * TEMPO

    triggered_break = break_path.is_a?(Array) ? break_path.sample : break_path

    sample triggered_break, start: timed_note.first, finish: timed_note.last, rate: tempo_adjusted_rate
    sleep timing_to_sleep(timing: timed_note, loop_length_in_seconds: LOOP_LENGTH)
  end
end

in_thread(name: :breakz) do
  loop do
    with_fx :reverb, room: 0.2, mix: 0.05 do; distort do;

      main_break = BREAK_PATHS.sample
      fill_in_break = (BREAK_PATHS - [main_break]).sample

      puts main_break
      puts fill_in_break

      timings = [[0.0, (0.25 * TEMPO)], [0.25, (0.5 * TEMPO)], [0.5, (0.75 * TEMPO)], [0.75, (1.0 * TEMPO)]]


      # MAIN BREAK
      [8, 4, 2].sample.times do
        first_drum_seq = [timings.first] + 7.times.collect { timings.sample }

        3.times do
          with_fx :slicer, pulse_width: LOOP_LENGTH do
            play_break_seq(drum_seq: first_drum_seq, break_path: main_break)
          end
        end

        fill_in_drum_seq = [timings.first] + 7.times.collect { timings.sample }

        # FILL IN BAR
        1.times do
          play_break_seq(drum_seq: fill_in_drum_seq, break_path: [fill_in_break, main_break])
        end
      end

      # BREAK DOWN
      [2, 1, 0].sample.times do
        sleep 4 * LOOP_LENGTH
      end
    end; end
  end
end

in_thread(name: :bass) do
  loop do
    use_synth %w(hoover prophet).sample

    section_scale = scale(:e2, :minor_pentatonic, num_octaves: [2, 1].sample)

    bass_seq = make_fixed_length_seq(length: 16.0 * (LOOP_LENGTH / 4.0), timings: SHORT_NOTE_LENGTH_DISTRIBUTION) do
      section_scale.sample
    end

    lead_for_bar = %w(square mod_fm mod_dsaw growl).sample
    chord_diff = [4].sample

    4.times do |index|

      bass_seq.shuffle! if index == 3
      distort do; #with_fx :rlpf, cutoff: rrand(50, 130), res: [0.2, 0.4].choose do; random_pan do; #

        bass_seq.each do |timed_note|
          use_synth %w(sine).sample

          base_note_params = [release: NOTE_LENGTH_DISTRIBUTION.select { |n| n <= timed_note.values.first }.choose,
                              amp: rrand(0.4, 0.8)]

          play timed_note.keys.first, *base_note_params

          base_note = timed_note.keys.first

          use_synth lead_for_bar

          with_fx :wobble, pulse_width: SHORT_NOTE_LENGTH_DISTRIBUTION.sample do
            harmonic_note_params = [release: NOTE_LENGTH_DISTRIBUTION.select { |n| n <= timed_note.values.first }.sample,
                                    amp: rrand(0.4, 0.6)]

            play_chord [base_note + 12, base_note + 12 + chord_diff], *harmonic_note_params
          end

          sleep timed_note.values.last
        end
      end; #end; end; #end
    end
  end
end

in_thread(name: :sampler) do
  loop do
    echo_params = [phase: SHORT_NOTE_LENGTH_DISTRIBUTION.sample,
                   mix: 0.9,
                   decay: LONG_NOTE_LENGTH_DISTRIBUTION.sample,
                   max_phase: SHORT_NOTE_LENGTH_DISTRIBUTION.max]

    with_fx :echo, *echo_params do
      with_fx :flanger do
        sample RAGGA_PATHS.sample, rate: HALF_SPEED_AND_DOUBLE_SPEED.sample
      end
    end
    sleep [16, 8, 4].sample * LOOP_LENGTH
  end
end
