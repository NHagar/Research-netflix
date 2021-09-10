# %%
import numpy as np
import pandas as pd
from scipy import stats

from tqdm import tqdm

# %%
# %%
def make_local_choices(user, items, local_count):
    local_choices = []
    dist = abs(items - user)
    for _ in range(local_count):
        local_choices.append(dist.argmin())
        dist = np.delete(dist, dist.argmin())
    
    return local_choices

def pl_percent(p, n):
    pl = stats.powerlaw.rvs(p, size=n)
    pcts = sorted([i/sum(pl) for i in pl])

    return pcts

# %%
n_users = 1_000
n_movies = 100
n_days = 30
pop_val = 0.5
pl_val = 1.5

users = stats.uniform.rvs(size=n_users)
movies = stats.uniform.rvs(size=n_movies)
tallies = [dict() for _ in range(n_days)]

# %%
for u in tqdm(users):
    choices = ((stats.binom.rvs(1, 1-pop_val, size=n_days)==1)).astype("object")
    choices[choices==True] = "gap"
    local = np.count_nonzero(choices==0)
    local_choices = make_local_choices(u, movies, local)
    choices[choices==False] = np.array(local_choices)

    for i in range(n_days):
        k = choices[i]
        if k in tallies[i]:
            tallies[i][k] += 1
        else:
            tallies[i][k] = 1

results = pd.DataFrame(tallies)

# %%
pl = pl_percent(pl_val, n_movies)
for it in range(n_days):
    gaps = results.loc[it, "gap"]
    if it > 0:
        p_notselected = 1 - (results[results.index<it].sum() / n_users)

#    init = list(zip([i[0] for i in enumerate(movies)], pl))
#    new_choices = np.random.choice([i[0] for i in init], gaps, p=[i[1] for i in init])

# %%
#- Init power law distribution (converted to % chance)
#- Assign to items
# Adjust based on prior selections
#- Run n draws, n = number of gaps
# Update counts
# Create next power law distribution based on updated counts 

# %%

# %%
df = pd.DataFrame(tallies)
# %%
df[df.index<20][38].sum()
# %%

# %%
pl
# %%
it = results.iloc[1]
# %%
it[it.index!=True].index
# %%
