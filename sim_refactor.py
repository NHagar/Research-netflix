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
    pcts = np.array(list(enumerate(pcts)))

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

# %%
for i in tqdm(range(0, n_days)):
    empty = np.argwhere(results[:, i]==0).astype(np.uint32)
    empty = empty.reshape((empty.shape[0],))
    if i==0:
        # Add 1 to remain consistent with other correction
        options = pl[:, 0] + 1
        weights = pl[:, 1]
        weights /= sum(weights)
        choices = np.random.choice(options, size=len(empty), p=weights)
    else:
        choices = []
        # Vectorize this
        subset_empty = results[empty, :i]
        items_expanded = np.tile(pl[:,0] + 1, (len(subset_empty), 1)).astype(np.uint16)
        its = 0
        for col in subset_empty.T:
            its+=1
            col = col.reshape((len(subset_empty), 1))
            items_expanded = items_expanded[col!=items_expanded].reshape((len(col), n_movies - its))
        
        weights_expanded = pl[items_expanded - 1]
        # https://stackoverflow.com/questions/47722005/vectorizing-numpy-random-choice-for-given-2d-array-of-probabilities-along-an-a
        choice_indices = (weights_expanded.cumsum(1)[:,:,1] > np.random.rand(weights_expanded.shape[0])[:,None]).argmax(1)
        choices = weights_expanded[range(len(weights_expanded)), choice_indices, 0]
    # Assign choices
    results[empty, i] = choices
    # Update rankings

# PL draw before local causes collisions