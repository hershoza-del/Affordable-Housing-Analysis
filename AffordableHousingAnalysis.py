#importing libraries

import os
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.ticker import ScalarFormatter
from matplotlib.ticker import StrMethodFormatter
import textwrap

#filtering the initial csv

text_cols = [
    "Project ID",
    "Project Name",
    "Program Group",
    "Extended Affordability Only",
    "Prevailing Wage Status",
    "Planned Tax Benefit",
]

df = pd.read_csv("/Users/hershoza/Downloads/Affordable_Housing_Production_by_Project_20261107.csv", 
                 thousands=",",
                 dtype={col: str for col in text_cols},
                 )

#brief analysis of initial csv 

print(df.shape)
print(df.info())
print(df.describe())
print(df.isnull().sum())
print(df.duplicated().sum())

#changing the initial csv

df = df.drop(columns=["Project Name", "Project Completion Date", "Planned Tax Benefit",
                      "Counted Rental Units", "Counted Homeownership Units", "Senior Units"])

df["Project Start Date"] = pd.to_datetime(df["Project Start Date"], format="%m/%d/%Y").dt.date

df["Extended Affordability Only"] = df["Extended Affordability Only"].map({"Yes": True, "No": False})

df["Prevailing Wage Status"] = df["Prevailing Wage Status"].replace("Non Prevailing Wage", "Non-Prevailing Wage")

#where my charts will be saved as a separate folder

folder_name = os.path.join(os.path.expanduser("~"), "affordable housing analysis charts")
os.makedirs(folder_name, exist_ok=True)

def save_path(filename):
    return os.path.join(folder_name, filename)

print(f"Charts will be saved in: {folder_name}")

#scatterplot graph

fig, ax1 = plt.subplots(figsize=(8, 5))
ax1.scatter(df["Total Units"], df["All Counted Units"] / df["Total Units"] * 100, s=8, alpha=0.3, color="teal")
ax1.set_xscale("log")
ax1.xaxis.set_major_formatter(ScalarFormatter())
ax1.axhline(100, ls="--", color="red") # 100% affordable line
ax1.text(1, 103, "100% affordable", color="red", fontsize=9)   # label the red line
ax1.axhspan(18, 32, color="gray", alpha=0.15)                  # shade the mixed-income band
ax1.text(2000, 25, "Mixed-income\n(20–30%)", fontsize=9, va="center")
ax1.set_ylim(-3, 108)                                          # room for the line label
ax1.grid(axis="y", alpha=0.3)                                  # light horizontal gridlines
ax1.spines[["top", "right"]].set_visible(False)                # cleaner frame
ax1.set_xlabel("Total units")
ax1.set_ylabel("Affordable share of units (%)")
ax1.set_title("Share of each project that is affordable, by project size")
fig.tight_layout()
fig.savefig(save_path("scatterplot.png"), dpi=150)
plt.close(fig)

#barchart graph

fig, ax2 = plt.subplots(figsize=(8, 5))
tiers = ["Extremely Low Income Units", "Very Low Income Units", "Low Income Units",
         "Moderate Income Units", "Middle Income Units"] # keep this order
short_labels = ["Extremely\nLow", "Very\nLow", "Low", "Moderate", "Middle"]
totals = df[tiers].sum()
bars = ax2.bar(short_labels, totals, color="steelblue", edgecolor="black")
ax2.bar_label(bars, labels=[f"{p:.0%}" for p in totals / totals.sum()], padding=3)
ax2.set_ylabel("Units")
ax2.set_title("Affordable units by income tier")
fig.tight_layout()
fig.savefig(save_path("barchart.png"), dpi=150)
plt.close(fig)

#boxplot graph

fig, ax3 = plt.subplots(figsize=(8, 5))
names, groups = zip(*[(n, g["All Counted Units"]) for n, g in df.groupby("Program Group")])
lebels = [textwrap.fill(n, 14) + f"\n(n={len(g)})" for n, g in zip(names, groups)]
ax3.boxplot(groups, tick_labels=lebels, patch_artist=True,                                          
            boxprops=dict(facecolor="lightgreen", edgecolor="black"),    
            medianprops=dict(color="black"),                            
            flierprops=dict(markeredgecolor="gray", alpha=0.5)) 
ax3.set_yscale("log") 
ax3.yaxis.set_major_formatter(lambda x, pos: f"{x:.0f}")
ax3.set_ylabel("Affordable units per project")
ax3.set_title("Project size by program group")
fig.tight_layout()
fig.savefig(save_path("boxplot.png"), dpi=150)
plt.close(fig)

#exporting changes as a new csv and excel file to analyze later

df.to_csv("/Users/hershoza/Downloads/Affordable_Housing_Analysis.csv")
df.to_excel("/Users/hershoza/Downloads/Affordable_Housing_Analysis.xlsx", index=False)