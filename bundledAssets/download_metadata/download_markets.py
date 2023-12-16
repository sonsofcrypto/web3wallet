import json
from typing import List, Dict
from coin_checko_api import CoinGeckoAPI
from utils import print_progress


def download_all_coins(api: CoinGeckoAPI) -> List[Dict[str, any]]:
    url = 'https://api.coingecko.com/api/v3/coins/list?include_platform=true'
    result = api.fetch_content(url)
    return json.loads(result)


def markets_url(page: int) -> str:
    url = "https://api.coingecko.com/api/v3/coins/markets"
    url += "?vs_currency=usd&order=market_cap_desc&per_page=250&page=" + str(page)
    url += "&sparkline=false&price_change_percentage=24h"
    return url


def download_markets(api: CoinGeckoAPI) -> List[Dict[str, any]]:
    page_total = int(len(download_all_coins(api)) / 250)
    page = 1
    result_markets = list()
    while True:
        response = api.fetch_content(markets_url(page))
        if response is None:
            print_progress('Unexpected error (markets):', page, page_total)
            print("Failed requests", api.failed_requests)
            raise Exception('Failed to laod markets')
        page_markets = json.loads(response)
        result_markets += page_markets
        print_progress('Download markets', page, page_total)
        if len(page_markets) == 0:
            print_progress('Completed', page, page_total)
            break
        page += 1

    return result_markets
