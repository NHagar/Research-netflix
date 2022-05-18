import argparse
import itertools
import numpy as np
import pandas as pd

from tqdm import tqdm

import simulation, evaluation

df = pd.read_csv("./data/all-weeks-countries.tsv", sep='\t')
df.week = pd.to_datetime(df.week)
df.loc[:, 'item_title'] = df.apply(lambda x: x.season_title if type(x.season_title)!=float else x.show_title, axis=1)
empirical = df[(df.country_name=="United States") & (df.category=="TV")]
empirical = empirical.drop(columns=['country_iso2', 'category', 'show_title', 'season_title'])
n_weeks = empirical.week.nunique()
n_items = empirical.item_title.nunique()

time_empirical = evaluation.time_on_list(empirical, "item_title", "week")
churn_empirical = evaluation.churn(empirical, "item_title", "week")
transitions_empirical = evaluation.movement_prob(empirical, "item_title", "week", "weekly_rank")

# params
parser = argparse.ArgumentParser(description="Run simulation, sweeping over parameters.")
# pop range
parser.add_argument("--popularity_range", type=float, nargs=2, default=[0, 1], help="Range of popularity values.")
# pop step
parser.add_argument("--popularity_step", type=float, default=0.2, help="Step size of popularity values.")
# pl range
parser.add_argument("--powerlaw_range", type=float, nargs=2, default=[1, 2], help="Range of power law distribution values.")
# pl step
parser.add_argument("--powerlaw_step", type=float, default=0.2, help="Step size of power law distribution values.")
# agent count
parser.add_argument("--n_agents", type=int, default = 100_000, help="Number of agents to simulate.")

# get params for simulation runs
args = parser.parse_args()
agent_count = args.n_agents
pop_range = list(np.linspace(args.popularity_range[0], args.popularity_range[1], int((args.popularity_range[1] - args.popularity_range[0]) // args.popularity_step) + 1))
pl_range = list(np.linspace(args.powerlaw_range[0], args.powerlaw_range[1], int((args.powerlaw_range[1] - args.powerlaw_range[0]) // args.powerlaw_step) + 1))
param_sweep = list(itertools.product(pop_range, pl_range))

results = []
for pair in tqdm(param_sweep):
    pop = pair[0]
    pl = pair[1]
    sim = simulation.Simulation(n_items, agent_count, n_weeks, pop, pl)
    sim.init_simulation()
    sim.run_simulation()
    time_sim = evaluation.time_on_list(sim.top_ten, "movie", "iteration")
    churn_sim = evaluation.churn(sim.top_ten, "movie", "iteration")
    transitions_sim = evaluation.movement_prob(sim.top_ten, "movie", "iteration", "rank")
    time_compare = evaluation.compare_distributions(time_empirical, time_sim)
    churn_compare = evaluation.compare_distributions(churn_empirical, churn_sim)
    transitions_compare = evaluation.compare_distributions(transitions_empirical, transitions_sim)
    results.append({'pop': pop, 
                    'pl': pl,
                    'time_ks': time_compare,
                    'churn_ks': churn_compare,
                    'mean_jsd': transitions_compare})

results_df = pd.DataFrame(results)
results_df.to_csv(f"./data/results_{agent_count}_{n_items}_{n_weeks}.csv", index=False)