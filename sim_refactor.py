# %%
import collections

import numpy as np
from scipy import stats

from tqdm import tqdm
# %%
n_users = 200_000_000
n_movies = 100
n_days = 30
pop_val = 0.5
# %%
users = stats.uniform.rvs(size=n_users)
movies = stats.uniform.rvs(size=n_movies)
tallies = [dict() for i in range(n_days)]

# %%
def make_local_choices(user, items, local_count):
    local_choices = []
    dist = abs(items - user)
    for i in range(local_count):
        local_choices.append(dist.argmin())
        dist = np.delete(dist, dist.argmin())
    
    return local_choices


# %%
for u in tqdm(users):
    choices = ((stats.binom.rvs(1, 1-pop_val, size=n_days)==1)).astype("object")
    local = np.count_nonzero(choices==0)
    local_choices = make_local_choices(u, movies, local)
    choices[choices==False] = np.array(local_choices)

    for i in range(n_days):
        k = choices[i]
        if k in tallies[i]:
            tallies[i][k] += 1
        else:
            tallies[i][k] = 1

# %%
