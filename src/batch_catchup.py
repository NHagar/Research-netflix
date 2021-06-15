# %%
from bs4 import BeautifulSoup
import pandas as pd
import requests



# %%
r = requests.get("https://www.whats-on-netflix.com/most-popular/")
# %%
soup = BeautifulSoup(r.text)
# %%
table = soup.find(text="United States Top 10 Movies & TV Series on Netflix").find_next("table")
# %%
movies = []
tv = []
for i in table.find_all("tr"):
    cols = i.find_all("td")
    if len(cols)>0:
        rank = cols[0].text.strip()
        movie = cols[1].text.strip()
        tv_show = cols[2].text.strip()
        movies.append({"rank": rank, "title": movie})
        tv.append({"rank": rank, "title": tv_show})

# %%
pd.DataFrame(movies)
# %%
pd.DataFrame(tv)
# %%
