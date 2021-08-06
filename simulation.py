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
    pop: float
    ranks: List = field(default_factory=lambda: [])
    selections: int = 0

    def reset_selections(self):
        self.selections = 0

@dataclass
class Simulation:
    def __init__(self,
                 movie_count: int,
                 user_count: int,
                 iterations: int,
                 pop_param: float,
                 pl_param: float):
        self.movie_count = movie_count
        self.user_count = user_count
        self.iterations = iterations
        self.pop_param = pop_param
        self.pl_param = pl_param

        # init preference distribution
        user_prefs = stats.uniform.rvs(size=user_count)
        movie_prefs = stats.uniform.rvs(size=movie_count)
        # init popularity distribution
        pop = self._gen_popularity_distribution()

        self.movies = [Movie(id=i, pref=movie_prefs[i], pop=pop[i]) for i in range(0, self.movie_count)]
        self.users = [User(i, pref=user_prefs[i]) for i in range(0, self.user_count)]        
        
    def _gen_popularity_distribution(self):
        dist = 1 - stats.powerlaw.rvs(self.pl_param, size=self.movie_count)
        return dist

    def _rank_movies(self):
        ""
        # For each user
        # Remove movies in memory
        # Weighted coin flip
        # If global
            # Weighted draw based on pop
        # If local
            # Closest pref value
        # Store selection in user memory
        # Iterate movie counter

    def _select_items(self):
        ""

    def run_iteration(self):
        ""


s = Simulation(movie_count=100, 
               user_count=300, 
               iterations=5, 
               pop_param=0.6, 
               pl_param=5)

print(s.movies)
print(s.users)