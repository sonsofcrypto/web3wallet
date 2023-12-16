from enum import Enum
from coin_checko_api import CoinGeckoAPI
from typing import List, Dict
from utils import write_json_file, print_progress, read_json_file
import pandas as pd
import json
import os


class CandleInterval(Enum):
    # Daily only available t - 3 months
    DAILY = 1
    # 1 day from current time = 5 minute interval data
    # 2 - 90 days of date range = hourly data
    # above 90 days of date range = daily data (00:00 UTC)
    AUTO = 2

    def url_query_params(self) -> str:
        match self:
            case CandleInterval.DAILY:
                return "&days=180&interval=daily"
            case CandleInterval.AUTO:
                return "&days=max"

    def folder_name(self) -> str:
        match self:
            case CandleInterval.DAILY:
                return "candles_daily"
            case CandleInterval.AUTO:
                return "candles_auto"


def download_candle_datas(
    ids: List[str],
    interval: CandleInterval,
    api: CoinGeckoAPI
):
    ids_cnt = len(ids)
    for idx, coingecko_id in enumerate(ids):
        print_progress("Downloading candles " + coingecko_id, idx, ids_cnt)
        data = download_candle_data(coingecko_id, interval, api)
        if data is not None:
            write_json_file(
                "data/" + interval.folder_name() + "/" + coingecko_id + ".json",
                data
            )


def load_candles_by_interval(
    interval: CandleInterval = CandleInterval.DAILY
) -> Dict[str, List[List[any]]]:
    files = os.listdir("data/" + interval.folder_name())
    total = len(files)
    candles_data: Dict[str, List[List[any]]] = dict()

    for idx, file in enumerate(files):
        coingecko_id = file.replace('.json', '')
        candles = read_json_file("data/" + interval.folder_name() + "/" + file)
        if len(candles) > 0:
            candles_data[coingecko_id] = candles
        print_progress("Loading " + interval.folder_name(), idx, total, True)

    return candles_data


def download_candle_data(
    id: str,
    interval: CandleInterval,
    api: CoinGeckoAPI
) -> List[Dict[str, any]]:
    url = "https://api.coingecko.com/api/v3/coins/" + id + "/ohlc"
    url += "?vs_currency=usd&precision=full" + interval.url_query_params()
    response = api.fetch_content(url)
    return None if response is None else json.loads(response)


def daily_candle_data_to_df(candle_data: List[List[any]]) -> pd.DataFrame:
    df = pd.DataFrame(
        data={
            'timestamp': list(map(lambda x: int(x[0] / 1000), candle_data)),
            "open": list(map(lambda x: x[1], candle_data)),
            "high": list(map(lambda x: x[2], candle_data)),
            "low": list(map(lambda x: x[3], candle_data)),
            "close": list(map(lambda x: x[4], candle_data))
        }
    )
    df = df.set_index('timestamp')
    return df
