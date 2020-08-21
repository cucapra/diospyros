import sys
import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np

matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42
matplotlib.rcParams['text.usetex'] = True


def plot(df):
    """
    Generates an ablation plot using the given data frame.
    """
    # Nature has a 0 timeout because we want it to be at the top.
    df['timeout'] = df['name'].map(
        lambda x: 0 if x == 'nature' else int(x.split('-')[1]))
    # Cleanup the kernel names
    df['name'] = df['name'].map(
        lambda x: x if x == 'nature' else x.split('-')[1])
    print(df)
    df = df.sort_values(['timeout'])

    # Set SNS formatting
    sns.set(font_scale=1.07)

    ax = sns.barplot(
        y='name',
        x='cycles',
        color=(0.2, 0.4, 0.6, 0.6),
        data = df,
    )
    locs, labels = plt.xticks()

    ax.legend(loc=1)
    ax.set_ylabel('Timeout (seconds)')
    ax.set_xlabel('Simulation cycles')
    plt.savefig('ablation.pdf', bbox_inches='tight')

if __name__ == '__main__':

    if len(sys.argv) < 2:
        print('Missing path to the ablation CSV')
        exit(1)

    df = pd.read_csv(sys.argv[1])
    plot(df)
