from dataclasses import dataclass, field
from typing import List

import scipy.stats as stats

@dataclass
class User:
    id: int
    pref: float
    memory: List = field(default_factory=lambda: [])

@dataclass
class Movie:
    id: int
    pref: float
    pop_init: float
    ranks: List = field(default_factory=lambda: [])


@dataclass
class Simulation:
    movie_count: int
    user_count: int
    iterations: int
    pop_param: float
    pl_param: float

    def init_sim(self):
        # init preference distribution
        user_prefs = stats.uniform.rvs(size=self.user_count)
        movie_prefs = stats.uniform.rvs(size=self.movie_count)
        # init popularity distribution
        pop = stats.uniform.rvs(self.pl_param, size=self.movie_count)

        self.movies = [Movie(id=i, pref=movie_prefs[i], pop_init=pop[i]) for i in range(0, self.movie_count)]
        self.users = [User(i, pref=user_prefs[i]) for i in range(0, self.user_count)]

    def rank_movies(self):
        ""


s = Simulation(100, 300, 5, 0.6, 1.5)
s.init_sim()
print(s.movies)
print(s.users)