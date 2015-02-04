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
