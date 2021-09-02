# %%
import numpy as np
from scipy import stats

# %%
n_users = 1000
n_movies = 100
n_days = 30
pop_val = 0.5
# %%
users = stats.uniform.rvs(size=n_users)
movies = stats.uniform.rvs(size=n_movies)
# %%
choices = stats.binom.rvs(1, 1-pop_val, size=n_days)==1
u = users[0]
local = np.count_nonzero(choices==0)
# %%
local_choices = []
dist = abs(movies - u)
for i in range(local):
    local_choices.append(dist.argmin())
    dist = np.delete(dist, dist.argmin())
# %%
local_choices
# %%
choices
# %%
