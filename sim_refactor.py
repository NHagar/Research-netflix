# %%
import collections
import random

import numpy as np
import pandas as pd
from scipy import stats

from tqdm import tqdm

# %%
def pl_percent(p, n):
    """Convert power law values to percentages (probabilities)"""
    pl = stats.powerlaw.rvs(p, size=n)
    pcts = [i/sum(pl) for i in pl]
    random.shuffle(pcts)
    pcts = dict(enumerate(pcts))
    pcts = dict(sorted(pcts.items(), key=lambda item: item[1]))

    return pcts

# %%
# Simulation parameters
n_users = 100_000
n_movies = 3_800
n_days = 30
pop_val = 0.6
pl_val = 1.5


# %%
# Binary mask matrix - 0/1 for local/global
# Chunk and fill in
users = stats.uniform.rvs(size=n_users)
movies = stats.uniform.rvs(size=n_movies)

# %%
results = np.empty((n_users, n_days), dtype=np.uint16)

init = np.empty((n_users, n_days), dtype=bool)
for i in tqdm(range(0, n_days)):
    choices = stats.binom.rvs(1, pop_val, size=n_users)==1
    init[:,i] = choices

# %%
for i in tqdm(range(0, n_users)):
    c = n_days - np.count_nonzero(init[i, :])
    # Add 1 to avoid collisions w/unfilled 0s
    cut = abs(users[i] - movies).argsort()[:c] + 1

    f = np.argwhere(init[i, :]==False).astype(np.uint32)
    f = f.reshape((f.shape[0],))

    results[i, f] = cut

# %%
pl = pl_percent(pl_val, n_movies)
movie_indices = [i + 1 for i in pl.keys()]

# %%
for i in tqdm(range(0, n_days)):
    empty = np.argwhere(results[:, i]==0).astype(np.uint32)
    empty = empty.reshape((empty.shape[0],))
    if i==0:
        # Add 1 to remain consistent with other correction
        options = movie_indices
        weights = np.fromiter(pl.values(), dtype=float)
        weights /= sum(weights)
        choices = np.random.choice(options, size=len(empty), p=weights)
    else:
        choices = []
        weights = np.fromiter(pl.values(), dtype=float)
        # Vectorize this
        subset_empty = results[empty, :i]
        items_expanded = np.resize(movie_indices, (len(subset_empty), len(movie_indices)))
        weights_expanded = np.resize(weights, (len(subset_empty), len(weights)))
        options = items_expanded[subset_empty!=items_expanded].reshape((subset_empty.shape[0], 
                                                               items_expanded.shape[1] - subset_empty.shape[1]))
        weights_expanded = weights_expanded[subset_empty!=items_expanded].reshape((subset_empty.shape[0], 
                                                               weights_expanded.shape[1] - subset_empty.shape[1]))
        # https://stackoverflow.com/questions/47722005/vectorizing-numpy-random-choice-for-given-2d-array-of-probabilities-along-an-a
        choice_indices = (weights_expanded.cumsum(1) > np.random.rand(weights_expanded.shape[0])[:,None]).argmax(1)
        choices = options[np.arange(len(options)),i]
    # Assign choices
    results[empty, i] = choices
    # Update rankings
    

# %%
