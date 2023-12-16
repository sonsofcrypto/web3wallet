from enum import Enum
from coin_checko_api import CoinGeckoAPI
from utils import print_progress, write_json_file, read_json_file, get_info, set_info
from typing import List, Dict
from datetime import datetime
from dateutil.relativedelta import relativedelta
import json
import os
import pandas as pd


class ChartInterval(Enum):
    # Daily only available t - 3 months
    DAILY = 1
    # 1 day from current time = 5 minute interval data
    # 2 - 90 days of date range = hourly data
    # above 90 days of date range = daily data (00:00 UTC)
    AUTO = 2
    # Turns out when querying full range. Daily candles are returned up to the
    # present
    FULL = 3

    def folder_name(self) -> str:
        match self:
            case ChartInterval.DAILY:
                return "chart"
            case ChartInterval.AUTO:
                return "chart_auto"
            case ChartInterval.FULL:
                return "chart_full"


def download_chart_by_interval(
    ids: List[str],
    interval: ChartInterval,
    api: CoinGeckoAPI
):
    ids_cnt = len(ids)
    info = get_info()
    _from = from_for_interval(interval)
    to = to_for_interval(interval)
    info[interval.folder_name() + "from"] = _from
    info[interval.folder_name() + "to"] = to
    set_info(info)

    for idx, coingecko_id in enumerate(ids):
        msg = "Downloading " + interval.folder_name() + " " + coingecko_id
        print_progress(msg, idx, ids_cnt)
        data = download_chart_data(coingecko_id, _from, to, api)
        if data is not None:
            write_json_file("data/" + interval.folder_name() + "/" + coingecko_id + ".json", data)


def download_chart_datas(ids: List[str], _from: int, to: int, api: CoinGeckoAPI):
    ids_cnt = len(ids)
    for idx, coingecko_id in enumerate(ids):
        print_progress("Downloading chart " + coingecko_id, idx, ids_cnt)
        data = download_chart_data(coingecko_id, _from, to, api)
        if data is not None:
            write_json_file("data/chart/" + coingecko_id + ".json", data)


def download_chart_data(
    id: str,
    _from: int,
    to: int,
    api: CoinGeckoAPI,
) -> List[Dict[str, any]] | None:
    url = "https://api.coingecko.com/api/v3/coins/"
    url += id + "/market_chart/range?vs_currency=usd"
    url += "&from={}&to={}&precision=full".format(_from, to)

    response = api.fetch_content(url)
    return None if response is None else json.loads(response)


def load_chart_by_interval(
    interval: ChartInterval = ChartInterval.DAILY
) -> Dict[str, Dict[str, any]]:
    files = os.listdir("data/" + interval.folder_name())
    total = len(files)
    charts: Dict[str, Dict[str, any]] = dict()

    for idx, file in enumerate(files):
        coingecko_id = file.replace('.json', '')
        chart = read_json_file("data/" + interval.folder_name() + "/" + file)
        if len(chart['prices']) > 0:
            charts[coingecko_id] = chart
        print_progress("Loading " + interval.folder_name(), idx, total, True)

    return charts


def chart_data_to_df(chart_data: List[Dict[str, any]], ) -> pd.DataFrame:
    tss = map(lambda x: int(x[0] / 1000), chart_data["prices"])
    vals = map(lambda x: x[1], chart_data["prices"])
    df = pd.DataFrame(data={'timestamp': tss, "price": vals})
    df = df.set_index('timestamp')

    tss = map(lambda x: int(x[0] / 1000), chart_data["market_caps"])
    vals = map(lambda x: x[1], chart_data["market_caps"])
    df_mcap = pd.DataFrame(data={'timestamp': tss, "market_cap": vals})
    df_mcap = df_mcap.set_index('timestamp')
    df = pd.concat([df, df_mcap], axis=1)

    tss = map(lambda x: int(x[0] / 1000), chart_data["total_volumes"])
    vals = map(lambda x: x[1], chart_data["total_volumes"])
    df_vol = pd.DataFrame(data={'timestamp': tss, "total_volume": vals})
    df_vol = df_vol.set_index('timestamp')
    df = pd.concat([df, df_vol], axis=1)
    df = df.rename(columns={'total_volume': 'volume'})

    return df


def from_for_interval(interval: ChartInterval) -> int:
    match interval:
        case ChartInterval.DAILY:
            return 0
        case ChartInterval.AUTO:
            return int((datetime.now() - relativedelta(months=3)).timestamp())
        case ChartInterval.FULL:
            return 0


def to_for_interval(interval: ChartInterval) -> int:
    match interval:
        case ChartInterval.DAILY:
            return int((datetime.now() - relativedelta(months=3)).timestamp())
        case ChartInterval.AUTO:
            return int(datetime.now().timestamp())
        case ChartInterval.FULL:
            return int(datetime.now().timestamp())
