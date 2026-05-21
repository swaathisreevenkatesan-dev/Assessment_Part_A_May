# Importing necessary libraries
import numpy as np
import pandas as pd
from sklearn.metrics import f1_score, precision_recall_curve, roc_curve
from sklearn.metrics import precision_score, recall_score

#Reading the data from csv file
df = pd.read_csv("analysis_data_may.csv")

# Trying to understand if the data is imblanced or balanced
result = df.groupby("stayed_active_180d").size()
result

# as the class is imbalanced, F1 score evaluation is the better metric to use. 
# In simple words, the point where recall and precision curve intersects gives the optimum threshold to split active from non active
def generate_threshold_table(csv_filepath):
    # 1. Load the dataset
    df = pd.read_csv(csv_filepath)

    #convert %s to decimals
    if df["class_pred"].dtype == "object":
        df["class_pred"] = (
            df["class_pred"].str.rstrip("%").astype("float") / 100.0
        )

    y_true = df["stayed_active_180d"].astype(int)
    y_scores = df["class_pred"]

    # thresholds to be considered
    thresholds = [0.10,0.20,0.30,0.40,0.50, 0.60, 0.70, 0.75, 0.80, 0.85, 0.90, 0.95]

    table_data = []

    # For each threshold
    for t in thresholds:

        y_pred = (y_scores >= t).astype(int)

        # Calculate metrics (zero_division=0 handles cases where no samples are predicted as active)
        precision = precision_score(y_true, y_pred, zero_division=0)
        recall = recall_score(y_true, y_pred, zero_division=0)

        if (precision + recall) > 0:
            f1 = 2 * (precision * recall) / (precision + recall)
        else:
            f1 = 0.0

        table_data.append(
            {
                "Threshold": f">={int(t*100)}%",
                "Recall (Sensitivity)": f"{recall:.2%}",
                "Precision": f"{precision:.2%}",
                "F1-Score": f"{f1:.2%}",
            }
        )


    output_df = pd.DataFrame(table_data)

    print("\n=== OPTIMIZATION SUMMARY TABLE ===")
    print(output_df.to_string(index=False))

generate_threshold_table("analysis_data_may.csv")

import pandas as pd
from sklearn.metrics import confusion_matrix

# text to float
if df["class_pred"].dtype == "object":
    df["class_pred"] = df["class_pred"].str.rstrip("%").astype("float") / 100.0

# threshold cutoff for 30%
y_true = df["stayed_active_180d"].astype(int)
y_pred = (df["class_pred"] >= 0.30).astype(int)

# Confusion Matrix
tn, fp, fn, tp = confusion_matrix(y_true, y_pred).ravel()

print("Confusion Matrix")
print(f"True Negatives (TN):  {tn}")
print(f"False Positives (FP): {fp}")
print(f"False Negatives (FN): {fn}")
print(f"True Positives (TP):  {tp}")
