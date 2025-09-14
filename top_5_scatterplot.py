import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

# read csv file
ranked_df = pd.read_csv("top50_ranked.csv")
top5_df = pd.read_csv("top_five.csv")
print(ranked_df.head())
# print(top5_df.head())

sns.scatterplot(
    data=ranked_df[ranked_df["is_top5"] == 'f'],
    x="rating", y="review_count",
    color="#9e9e9e", alpha=0.25, s=60, edgecolor=None, label="Others"
)

ax = sns.scatterplot(
    data=top5_df,
    x="rating", y="review_count",
    color="#ff826b", s=100, edgecolor="None", label="Top 5"
)

# labels for top 5
for _, r in top5_df.iterrows():
    ax.text(r["rating"]+0.025, r["review_count"]+3, r["name"], rotation=45,fontsize=9)

plt.title('Top 5 Businesses')
plt.xlabel('Rating')
plt.ylabel('Review Count')
plt.show()