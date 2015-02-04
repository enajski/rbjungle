require "~/experiments/rbjungle/methods.rb"
require "~/experiments/rbjungle/sounds.rb"
require "~/experiments/rbjungle/effects.rb"

verse1 = [:kick, :blip, :stab, :taci]
verse2 = [:kick, :stab, :cita, :blip]

define :drums do
  with_fx :ixi_techno, phase: 1, cutoff_min: 90, res: 0.1, mix: 0.2 do
    with_fx :bitcrusher, bits: rrand(8,16), sample_rate: rrand(4000, 10000) do
      with_fx :reverb, room: 0.2, mix: 0.05 do
        with_fx :echo, decay: 0.05, phase: [0.75, 1.5].choose do
          distort do
            4.times { verse verse1 }
            4.times { verse verse2 }
          end
        end
      end
    end
  end
end

in_thread(name: :looper) do
  loop do
    drums
  end
end
