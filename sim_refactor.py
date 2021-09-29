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
    pcts = list(enumerate(pcts))

    return pcts

# %%
# Simulation parameters
n_users = 1_000
n_movies = 100
n_days = 30
pop_val = 0.6
pl_val = 1.5


# %%
# Binary mask matrix - 0/1 for local/global
# Chunk and fill in
# %%
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

for i in tqdm(range(0, n_days)):
    empty = np.argwhere(results[:, i]==0).astype(np.uint32)
    empty = empty.reshape((empty.shape[0],))
    if i==0:
        # Add 1 to remain consistent with other correction
        options = [i[0] + 1 for i in pl]
        weights = [i[1] for i in pl]
        choices = np.random.choice(options, size=len(empty), p=weights)
    else:
        ""
    results[empty, i] = choices
    # Update ranking

# %%
len(init)
# %%
init.shape[1]
# %%
np.argwhere(results[:, 1]==0).astype(np.uint32)
# %%
e.reshape((e.shape[1],))
# %%
np.random.choice([i[0] for i in pl], size=600, p=[i[1] for i in pl])
# %%
len(results[empty,0])
# %%
len(choices)
# %%
len(empty)
# %%
results[:,0]
# %%
r = [i[0] for i in collections.Counter(results[:,0]).most_common()]
# %%
list(zip(r, sorted(weights, reverse=True)))
# %%
