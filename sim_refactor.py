# %%
import numpy as np
import pandas as pd
from scipy import stats

from tqdm import tqdm

# %%
def make_local_choices(user, items, local_count):
    """Calculate user-level choices based on item distance"""
    local_choices = []
    # Calculate distance between item and user values
    dist = abs(items - user)
    for _ in range(local_count):
        # Get the index of the closest item
        local_choices.append(dist.argmin())
        # Delete chosen item
        dist = np.delete(dist, dist.argmin())
    
    return local_choices

def pl_percent(p, n):
    """Convert power law values to percentages (probabilities)"""
    pl = stats.powerlaw.rvs(p, size=n)
    pcts = sorted([i/sum(pl) for i in pl])

    return pcts

# %%
# Simulation parameters
n_users = 1_000
n_movies = 100
n_days = 30
pop_val = 0.5
pl_val = 1.5

# Initialize agents, items, and selection counts
users = stats.uniform.rvs(size=n_users)
movies = stats.uniform.rvs(size=n_movies)
tallies = [dict() for _ in range(n_days)]

# %%
# For each user
for u in tqdm(users):
    # Determine which choices will be local/global
    choices = ((stats.binom.rvs(1, 1-pop_val, size=n_days)==1)).astype("object")
    # Mask global, local choices
    choices[choices==True] = "gap"
    local = np.count_nonzero(choices==0)
    # Make local choices
    local_choices = make_local_choices(u, movies, local)
    # Fill in local choices
    choices[choices==False] = np.array(local_choices)
    # Tally up selections of each item
    for i in range(n_days):
        k = choices[i]
        if k in tallies[i]:
            tallies[i][k] += 1
        else:
            tallies[i][k] = 1
# Make result dataframe
results = pd.DataFrame(tallies)

# %%
# Init power law values
pl = pl_percent(pl_val, n_movies)
# For each day
for it in range(n_days):
    # Count missing values for current day
    gaps = results.loc[it, "gap"]
    # If after the first iteration
    if it > 0:
        # TODO: This needs to follow a Bayesian approach
        # of updating selection probabilities through a 
        # combination of power law values and available user pool
        ""

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
it_selections = results.iloc[10].fillna(0).sort_values()

# %%
it_selections = it_selections[it_selections.index!="gap"]
# %%
# %%

# %%
type(p_notselected)
# %%
pl_df = pd.merge(pl_values, p_notselected, left_index=True, right_index=True)
pl_df.loc[:, "adjusted"] = pl_df.pl * pl_df.adjustment
# %%
np.random.choice(pl_df.index, 10, p=pl_df.adjusted)
# %%
