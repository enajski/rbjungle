# ENAY | enajski | @apogsasis

def intro; with_fx :distortion do; with_fx :reverb do
  sample_pattern = /(perc|ambi|guit)/
  samples = all_sample_names.to_a.select { |sn| sample_pattern.match(sn) }.shuffle
  samples.each do |sn|
    sample sn, pan: [-0.8, 0, 0.8].sample, rate: [0.05, 0.1, 0.2].sample, amp: 0.9
    sleep [0.15, 0.3, 0.6, 1.2, 2.4, 4.8].sample
  end
end;end;end

live_loop :atmo do
  intro
end

require "~/experiments/rbjungle/methods.rb"
require "~/experiments/rbjungle/sounds.rb"
require "~/experiments/rbjungle/effects.rb"
require "unimidi"

@client = SonicPi::OSC::UDPClient.new("192.168.1.107", 1234)

def osc1(pattern, msg)
  @client.send(pattern, msg) rescue nil
end

@midi = UniMIDI::Output.last

@midi.open

BREAK_PATHS = Dir.chdir("/Users/dev/Music/breakbeats/") do
# BREAK_PATHS = Dir.chdir("/Users/dev/Music/algobeats/") do
  Dir.glob("*.wav").map { |path| Dir.pwd + "/" + path }
end

RAGGA_PATHS = Dir.chdir("/Users/dev/Music/ragga_samples/") do
  Dir.glob("*.wav").map { |path| Dir.pwd + "/" + path }
end

TEMPO = 1.0
LOOP_LENGTH = 1.4 * TEMPO

NOTE_LENGTH_DISTRIBUTION = [(2 * LOOP_LENGTH), LOOP_LENGTH, (LOOP_LENGTH / 2), (LOOP_LENGTH / 4), (LOOP_LENGTH / 8)]

LONG_NOTE_LENGTH_DISTRIBUTION = [(4 * LOOP_LENGTH), (2 * LOOP_LENGTH),LOOP_LENGTH]

SHORT_NOTE_LENGTH_DISTRIBUTION = [(LOOP_LENGTH / 2), (LOOP_LENGTH / 4), (LOOP_LENGTH / 8)]

HALF_SPEED_AND_DOUBLE_SPEED = [1.5, 1.0, 0.5]

set_mixer_control! hpf: 124

live_loop :drums do
  with_fx :ixi_techno, phase: NOTE_LENGTH_DISTRIBUTION.sample, cutoff_min: 90, res: 0.1, mix: 0.05 do
    with_fx :bitcrusher, bits: rrand(8,16), sample_rate: rrand(8000, 16000), mix: 0.5 do
      with_fx :reverb, room: 0.2, mix: 0.05 do
        with_fx :echo, decay: 0.05, phase: [0.75, 1.5].choose, mix: 0.0 do
          verse1 = [:kick, :blip, :stab, :taci]
          verse2 = [:kick, :stab, :cita, :blip]
          verse3 = %w(kick blip puci stab)
          verse4 = %w(puci taci cita cita puci taci cii cii cii blip).shuffle

          distort do
            # 4.times { verse verse1 }
            # 4.times { verse verse2 }
            # 2.times { verse verse3 }
            # 2.times { verse verse4 }

            main_break = BREAK_PATHS.sample
            fill_in_break = (BREAK_PATHS - [main_break]).sample

            timings = [[0.0, 0.25], [0.25, 0.5], [0.5, 0.75], [0.75, 1.0]]

            # MAIN BREAK
            [4, 2].sample.times do
              first_drum_seq = [timings.first] + 7.times.collect { timings.sample }

              3.times do
                play_break_seq(drum_seq: first_drum_seq, break_path: main_break, length: LOOP_LENGTH)
              end

              fill_in_drum_seq = [timings.first] + 7.times.collect { timings.sample }

              # FILL IN BAR
              1.times do
                play_break_seq(drum_seq: fill_in_drum_seq, break_path: [fill_in_break, main_break], length: LOOP_LENGTH)
              end
            end

            # BREAK DOWN
            # [2, 1, 0].sample.times do
            #   sleep 4 * LOOP_LENGTH
            # end
          end
        end
      end
    end
  end
end

live_loop :sampler do
  echo_params = {phase: SHORT_NOTE_LENGTH_DISTRIBUTION.sample,
                 mix: 0.5,
                 decay: LONG_NOTE_LENGTH_DISTRIBUTION.sample * 4,
                 max_phase: SHORT_NOTE_LENGTH_DISTRIBUTION.max}

  with_fx :echo, echo_params do
    with_fx :flanger do
      sample RAGGA_PATHS.sample, rate: HALF_SPEED_AND_DOUBLE_SPEED.sample, amp: 0.8
    end
  end
  sleep [16, 8, 4].sample * LOOP_LENGTH
end


live_loop :bass do
  sync :drums

  section_scale = scale([:g2].sample, :minor_pentatonic, num_octaves: [2, 1].sample)

  bass_seq = make_fixed_length_seq(length: 16.0 * (LOOP_LENGTH / 4.0), timings: SHORT_NOTE_LENGTH_DISTRIBUTION) do
    section_scale.sample
  end

  bass_synth = %w(sine).sample
  lead_synth = %w(square mod_fm mod_dsaw growl).sample
  chord_diff = 4

  4.times do |index|

    bass_seq.shuffle! if index == 3
    distort do;

      bass_seq.each do |timed_note|
        use_synth bass_synth

        base_note_params = {release: NOTE_LENGTH_DISTRIBUTION.select { |n| n <= timed_note.values.first }.choose,
                            amp: rrand(0.2, 0.4)}

        # @midi.puts(0x90, timed_note.keys.first, 100)
        sleep base_note_params[:release]
        # @midi.puts(0x80, timed_note.keys.first, 100)
        sleep timed_note.values.last - base_note_params[:release]

        play timed_note.keys.first, base_note_params

        base_note = timed_note.keys.first

        use_synth lead_synth

        with_fx :wobble, pulse_width: SHORT_NOTE_LENGTH_DISTRIBUTION.sample do
          harmonic_note_params = {release: NOTE_LENGTH_DISTRIBUTION.select { |n| n <= timed_note.values.first }.sample,
                                  amp: rrand(0.2, 0.3)}

          # play_chord [base_note + 12, base_note + 12 + chord_diff], harmonic_note_params
        end
      end
    end
  end
end