# %%
import numpy as np
import scipy.stats as stats

# %%
n_movies = 1_000
n_users = 100

# %%
movies = np.sort(stats.uniform.rvs(size=n_movies)).reshape((1,n_movies))
users = np.sort(stats.uniform.rvs(size=100)).reshape((n_users, 1))
# %%
distances = abs(users - movies)

# %%
[i for i in enumerate(distances[0])]
# %%
