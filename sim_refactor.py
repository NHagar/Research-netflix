# %%
import numpy as np
from scipy import stats

from tqdm import tqdm
# %%
n_users = 1_000
n_movies = 100
n_days = 30
pop_val = 0.5
pl_val = 1.5
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

def pl_percent(p, n):
    pl = stats.powerlaw.rvs(p, size=n)
    pcts = [i/sum(pl) for i in pl]

    return pcts

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
init_pl = pl_percent(pl_val, n_movies)

# %%
# Init power law distribution (converted to % chance)
# Run n draws, n = number of gaps
# Update counts
# Create next power law distribution based on updated counts 
