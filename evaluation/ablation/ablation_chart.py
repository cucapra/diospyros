import sys
import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np

matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42
matplotlib.rcParams['text.usetex'] = True

palette = [
        (170/235, 170/235, 170/235), # gray    - Nature
        (140/235, 40/235, 93/235),   # magenta        - Diospyros
        ]

def plot(df):
    """
    Generates an ablation plot using the given data frame.
    """
    # Nature has a 10000 timeout because we want it to be at the bottom.
    df['timeout'] = df['name'].map(
        lambda x: 10000 if x == 'Nature' else int(x))
    # Cleanup the kernel names
    df['name'] = df['name'].map(
        lambda x: 'Nature Library' if x == 'Nature' else x)

    plt.rcParams['figure.figsize'] = (7, 3)

    print(df)
    df = df.sort_values(['timeout'])

    # Color palette hackery
    pal = df['name'].map(
        lambda x: palette[0] if x == 'Nature' else palette[1])

    # Set SNS formatting
    sns.set(font_scale=1.04, style="whitegrid")


    ax = sns.barplot(
        y='name',
        x='cycles',
        palette = pal,
        data = df,
        alpha=0.
    )
    locs, labels = plt.xticks()


    ax.set_ylabel('Timeout (seconds)')
    ax.set_xlabel('Simulation cycles, 10×10 10×10 MatMul')
    plt.savefig('ablation.pdf', bbox_inches='tight')

if __name__ == '__main__':

    if len(sys.argv) < 2:
        print('Missing path to the ablation CSV')
        exit(1)

    df = pd.read_csv(sys.argv[1])
    plot(df)
