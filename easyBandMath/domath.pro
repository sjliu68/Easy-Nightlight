function domath, x, c0, c1, c2
  y = c0+c1*float(x)+c2*float(x)*float(x)
  return, y
end