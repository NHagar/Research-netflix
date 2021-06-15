# %%
from time import sleep

from bs4 import BeautifulSoup
import pandas as pd
import requests
from tqdm import tqdm

# %%
base_url = "https://www.whats-on-netflix.com/most-popular/?dateselect="
dates = [i.date().strftime("%m-%d-%Y") for i in pd.date_range("2021-01-01", "2021-06-13")]

# %%
all_movies = []
all_tv = []
for i in tqdm(dates):
    date_encoded = i.replace("-", "%2F")
    request_url = f"{base_url}{date_encoded}"
    r = requests.get(request_url)
    sleep(1)
    soup = BeautifulSoup(r.text, features="html.parser")
    table = soup.find(text="United States Top 10 Movies & TV Series on Netflix").find_next("table")

    movies = []
    tv = []
    for row in table.find_all("tr"):
        cols = row.find_all("td")
        if len(cols)>0:
            rank = cols[0].text.strip()
            movie = cols[1].text.strip()
            tv_show = cols[2].text.strip()
            movies.append({"rank": rank, "title": movie})
            tv.append({"rank": rank, "title": tv_show})

    if len(movies)>0:
        movie_df = pd.DataFrame(movies)
        movie_df.loc[:, "date"] = i
        movie_df.loc[:, "type"] = "movie"
        all_movies.append(movie_df)
    if len(tv)>0:
        tv_df = pd.DataFrame(tv)
        tv_df.loc[:, "date"] = i
        tv_df.loc[:, "type"] = "tv"
        all_tv.append(tv_df)

# %%
pd.concat(all_movies).to_csv("../data/batch_movies.csv")
pd.concat(all_tv).to_csv("../data/batch_tv.csv")
# %%
