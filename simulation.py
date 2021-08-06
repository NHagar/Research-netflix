from dataclasses import dataclass, field
import random
from typing import List

import scipy.stats as stats
from tqdm import tqdm

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
    selections: int = 0

    def __eq__(self, other):
        return self.id == other.id
    
    def __hash__(self):
        return hash(self.id)

    def reset_selections(self):
        self.selections = 0

@dataclass
class Simulation:
    movie_count: int
    user_count: int
    iterations: int
    pop_param: float
    pl_param: float
    results: List = field(default_factory=lambda: [])
        
    def _gen_popularity_distribution(self):
        dist = 1 - stats.powerlaw.rvs(self.pl_param, size=self.movie_count)
        dist = sorted(dist)
        return dist

    def _item_selections(self):
        for user in self.users:
            # Get items not in user memory
            movies_unseen = list(set(self.movies) - set(user.memory))
            # Check for global/local influence
            influence = random.random() > self.pop_param
            if influence:
                # Weighted popularity draw
                weights = [i.pop for i in movies_unseen]
                selected_movie = random.choices(movies_unseen, weights, k=1)[0]
            else:
                # Closest preference value
                selected_movie = min(movies_unseen, key=lambda x: abs(x.pref - user.pref))
            # Store selection to user memory
            user.memory.append(selected_movie)
            # Record movie selection
            selected_movie.selections += 1

    def _record_results(self):
        # Save selection count for each item
        for movie in self.movies:
            result = {"movie": movie.id, "selections": movie.selections, "iteration": self.it}
            self.results.append(result)

    def init_simulation(self):
        # init preference distribution
        user_prefs = stats.uniform.rvs(size=self.user_count)
        movie_prefs = stats.uniform.rvs(size=self.movie_count)
        # init popularity distribution
        pop = self._gen_popularity_distribution()

        # init agents, items
        self.movies = [Movie(id=i, pref=movie_prefs[i], pop=pop[i]) for i in range(0, self.movie_count)]
        self.users = [User(i, pref=user_prefs[i]) for i in range(0, self.user_count)]

    def _end_iteration(self):
        # Set new popularity distribution
        pop = self._gen_popularity_distribution()
        self.movies = sorted(self.movies, key=lambda x: x.selections)
        for i in range(0, self.movie_count):
            self.movies[i].pop = pop[i]
        # Zero out selections
        for movie in self.movies:
            movie.reset_selections()

    def run_simulation(self):
        for i in tqdm(range(0, self.iterations)):
            self.it = i
            self._item_selections()
            self._record_results()
            self._end_iteration()

