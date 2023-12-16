from enum import Enum

from coin_checko_api import CoinGeckoAPI
from typing import List, Dict
import json
import pandas as pd
import os
from utils import write_json_file, print_progress


def download_coin_datas(
    ids: List[str],
    api: CoinGeckoAPI,
    skip_if_exists: bool = False
):
    ids_cnt = len(ids)
    for idx, coingecko_id in enumerate(ids):
        path = "data/coin/" + coingecko_id + ".json"
        if skip_if_exists and os.path.isfile(path):
            continue
        print_progress("Downloading coin " + coingecko_id, idx, ids_cnt)
        data = download_coin_data(coingecko_id, api)
        if data is not None:
            write_json_file(path, data)


def download_coin_data(
    id: str,
    api: CoinGeckoAPI
) -> Dict[str, any]:
    url = "https://api.coingecko.com/api/v3/coins/" + id + "?localization=en"
    url += "&tickers=false&market_data=true&community_data=false"
    url += "&developer_data=false&sparkline=false"
    response = api.fetch_content(url)
    return None if response is None else json.loads(response)


# def coins_data_to_df(candles: List[List[int]]) -> pd.DataFrame:
#     df = pd.DataFrame(columns=['timestamp', 'open', 'high', 'low', 'close'])
#     for idx, candle in enumerate(candles):
#         df.loc[idx] = candle
#     df['timestamp'] = df.apply(lambda x: int(x['timestamp'] / 1000), axis=1)
#     df = df.set_index('timestamp')
#     return df
#