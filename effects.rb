def coin_toss(probability, on_state: 1.0, off_state: 0.0)
  if rand < probability then on_state else off_state end
end

def distort(probability: 1.0, &block)
  with_fx :distortion, distort: 0.8, mix: coin_toss(probability, off_state: 0.2) do
    yield
  end
end

def random_pan(probability: 1.0, &block)
  with_fx :pan, pan: [-0.1, 0, 0.1].choose, mix: coin_toss(probability) do
    yield
  end
end
