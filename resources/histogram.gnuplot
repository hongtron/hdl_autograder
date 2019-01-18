# https://stackoverflow.com/a/2538846/5407447

binwidth=1
bin(x,width)=width*floor(x/width)
plot '/dev/stdin' using (bin($1,binwidth)):(1.0) smooth freq with boxes
