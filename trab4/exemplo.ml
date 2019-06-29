var a, tab[9], i, total;
console >> a;
for i in [0..8]
  tab[i] = a + i;
  total=0;
  for i in [10..18]
    total = total + tab[i-10];
    console << total / 9 << endl;
