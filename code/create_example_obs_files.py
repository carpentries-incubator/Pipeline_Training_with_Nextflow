

freqs = [10, 20, 30]
points = [
    "10deg_10deg",
    "20deg_10deg",
    "30deg_10deg",
]
nfiles = len(freqs) * len(points)

for file_i in range(nfiles):
    freq_i = file_i % len(freqs)
    point_i = file_i // len(freqs)
    with open(f"obs_{file_i+1}.dat", 'w') as f:
        f.write(f"#freq: {freqs[freq_i]} MHz\n")
        f.write(f"#date: 2022-11-15\n")
        f.write(f"#point: {points[point_i]}\n")
