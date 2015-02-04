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

def kick
  sample :bd_haus, rate: 1.0, start: 0.0, finish: 1.0, amp: 0.8
end

def blip
  sample :elec_blip, rate: 1.0, start: 0.0, finish: 1.0
end

def stab
  [lambda { sample :loop_industrial, rate: 1.5, start: 0.5, finish: 1.0, amp: 0.5 },
   lambda { sample :drum_cymbal_closed, rate: [0.9, 1.0].choose, start: 0.0, finish: 1.0 }].choose.call
end
