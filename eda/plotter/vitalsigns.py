import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv("data/vitalsigns.csv")
plt.style.use("fivethirtyeight")
# use dots to mark data points
ax = df.plot(subplots=True, x="charttime", figsize=(12, 18), marker="o", markersize=5, linestyle="-", linewidth=0.5)
ax[0].set_title("Vital Signs")
# rotate y-axis labels by 90°
plt.show()