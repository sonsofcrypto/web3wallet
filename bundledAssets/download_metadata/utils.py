import requests
import time
import platform
import json
import os
from datetime import datetime
from typing import List, Dict


def print_progress(prefix: str, curr: int, total: int, same_line: bool = True):
    page_str = 'idx: {} / {}'.format(curr, total)
    prog_str = ', {:.1%}'.format(float(curr) / float(total))
    space = '       '
    if same_line:
        print('\r', prefix, page_str + prog_str + space, end='')
    else:
        print(prefix, page_str + prog_str + space)


def std_headers():
    headers = requests.utils.default_headers()
    default_agent = headers['User-Agent']
    headers.update({'User-Agent': default_agent + ' (' + platform.platform() + ')'})
    return headers


def get_ip():
    try:
        endpoint = 'https://ipinfo.io/json'
        response = requests.get(endpoint, verify=True)
        if response.status_code != 200:
            return 'Status:', response.status_code, 'Problem with the request. Exiting.'
        data = response.json()
        return data['ip']
    except:
        print("Failed to obtain ip address")
        return None


def create_data_folders_if_needed():
    paths = [
        'data/candles_auto',
        'data/candles_daily',
        'data/chart',
        'data/chart_auto',
        'data/chart_full',
        'data/coin',
        'data/image',
    ]
    for path in paths:
        if not os.path.exists(path):
            os.makedirs(path)

def sleep(seconds: int):
    i = seconds
    while i > 0:
        i = i - 1
        print("sleep", i, get_ip())
        time.sleep(1)


def read_json_file(path: str) -> object:
    with open(path, 'r') as f:
        return json.load(f)


def write_json_file(path: str, data: any):
    # if data is not None:
    #     with open(path, 'w') as f:
    #         t = json.dumps(data)
    #         f.write(t)
    if data is None:
        return
    try:
        f = open(path, 'w')
        f.write(json.dumps(data))
        f.close()
    except IOError as err:
        print("I/O error: {}".format(err))


def get_info() -> Dict[any, any]:
    read_json_file_or_empty_dict('data/info.json')


def set_info(info: Dict[any, any]):
    write_json_file('data/info.json', info)


def read_json_file_or_empty_dict(path: str) -> Dict[any, any]:
    try:
        return read_json_file(path)
    except:
        return dict()


def read_json_file_or_empty_list(path: str) -> List[any]:
    try:
        return read_json_file(path)
    except:
        return list()


def year(timestamp: int) -> int:
    return int(datetime.utcfromtimestamp(timestamp).strftime('%Y'))


def month(timestamp: int) -> int:
    return int(datetime.utcfromtimestamp(timestamp).strftime('%m'))


def day_of_month(timestamp: int) -> int:
    return int(datetime.utcfromtimestamp(timestamp).strftime('%d'))


def year_month_str(timestamp: int) -> str:
    return datetime.utcfromtimestamp(timestamp).strftime('%Y-%m')


def year_month_keys(years: List[int], months: List[int]) -> List[str]:
    keys: List[str] = list()
    for year in years:
        for month in months:
            keys.append("{}-{:02d}".format(year, month))
    return keys


def large_num_short_format(num):
    num = float('{:.3g}'.format(num))
    magnitude = 0
    while abs(num) >= 1000:
        magnitude += 1
        num /= 1000.0
    return '{}{}'.format('{:f}'.format(num).rstrip('0').rstrip('.'), ['', 'K', 'M', 'B', 'T'][magnitude])

# db = mysql.connector.connect(
#     host=os.environ.get("DB_HOST"),
#     user=os.environ.get("DB_USER"),
#     passwd=os.environ.get("DB_PASS"),
#     database=os.environ.get("DB_NAME"),
# )
# cursor = db.cursor()

# sql = "INSERT INTO markets (coingecko_id, symbol, name, market_cap, market_cap_rank) "
# sql += "VALUES (%s, %s, %s, %s, %s)"
#
# i = 1
# for market in markets:
#     print('\r', 'writing', i, '/', len(markets), market['id'], market['name'], '               ', end='')
#     i += 1
#     val = (
#         market["id"][:24],
#         market["symbol"][:24],
#         market["name"][:64],
#         market["market_cap"],
#         market["market_cap_rank"],
#      )
#     cursor.execute(sql, val)
# db.commit()
