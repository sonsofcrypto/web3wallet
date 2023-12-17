from dotenv import load_dotenv
from typing import Dict, List
import utils
from coin_checko_api import CoinGeckoAPI, ExecPolicy
from download_candles import download_candle_datas, CandleInterval
from download_chart_data import download_chart_data, download_chart_datas, ChartInterval, download_chart_by_interval
from download_coin import download_coin_datas
from download_markets import download_all_coins, download_markets, print_progress
from download_image import download_image, ImgMeta, image_file_name
from vpn_switcher.vpn_switcher import VPNSwitcher
from utils import write_json_file, read_json_file
import datetime
import json
import os
from dateutil.relativedelta import relativedelta
from PIL import Image
from PIL import ImageColor
import numpy as np
import sklearn
import sklearn.cluster
import scipy
import scipy.cluster
import json
import shutil
import warnings
import copy

# Images only for ranked

load_dotenv()

bad_img_names = {
    'dust-protocol.': 'dust-protocol.png',
    'kompete.': 'kompete.png',
    'zeroswap.': 'zeroswap.png',
    'zigzag-2.': 'zigzag-2.png',
}

bad_img_to_remove = [
    'contract-dev-ai.jpg', 'bluesparrow.', 'neutrino-system-base-token.jpg',
    'historydao.jpg', 'sylo.svg', 'shiba-doge-burn.jpg', 'dogey-inu.jpg',
    'magical-blocks.jpg', 'cartman.jpg', 'yin-finance.jpg',
    'sappy-seals-pixl.jpg', 'divergence-protocol.jpg', 'intrinsic-number-up.jpg'
]

native_coins = ['ethereum']


def main():
    utils.create_data_folders_if_needed()
    api = CoinGeckoAPI(ExecPolicy.VPN)

    print("Downloading coins")
    # coins = download_all_coins(api)
    # write_json_file("data/coins.json", coins)
    coins = read_json_file('data/coins.json')
    print('Downloaded coins ', len(coins))

    # Download market data
    print("Downloading markets")
    # markets = download_markets(api)
    # write_json_file("data/markets.json", markets)
    markets = read_json_file('data/markets.json')
    print('Downloaded markets ', len(markets))
    print("Failed requests:", len(api.failed_requests), api.failed_requests)

    # Include only native or ethereum ERC20s
    coins = eth_native_and_erc20(coins)
    coins = change_id_to_coingecko(coins)
    markets_dict = transform_to_markets_dict(markets)
    coins = sort_by_rank(coins, markets_dict)
    coins_ranked_only = ranked_only_coins(coins, markets_dict)
    img_meta = img_metas(coins, markets_dict)
    img_meta_ranked_only = img_metas(coins_ranked_only, markets_dict)
    print('Filtered out unsupported, remaining count', len(coins))

    print("Downloading coin data")
    coin_gecko_ids = list(map(lambda x: x["coinGeckoId"], coins))
    download_coin_datas(coin_gecko_ids, api, True)
    print("Failed requests:", len(api.failed_requests), api.failed_requests)

    print('cache_currencies.json')
    coins = create_cache_currencies(coins)
    coins_arrs = cache_currencies_arrs(coins)
    # write_json_file('data/cache_currencies.json', coins)
    write_json_file('data/cache_currencies_1_arr.json', coins_arrs)
    print("Coins: ", len(coins))

    print('cache_markets.json')
    min_markets_dict = create_cache_markets(coins, markets_dict)
    min_markets_dict_arr = create_cache_markets_arr(coins, markets_dict)
    # write_json_file('data/cache_markets.json', min_markets_dict)
    write_json_file('data/cache_markets_arr.json', min_markets_dict_arr)

    print("Download images")
    download_image(img_meta, api, True)
    print("Failed requests:", len(api.failed_requests), api.failed_requests)

    print("Resizing")
    rename_known_bad_img_names()
    apply_override_images()
    resize_images()

    print('cache_metadatas.json')
    # cache_metadatas = create_cache_metadatas(coins)
    # write_json_file('data/cache_metadatas.json', cache_metadatas)
    cache_metadatas_sml_arr = create_cache_metadatas_arrs(
        create_cache_metadatas(coins, True),
        True
    )
    write_json_file('data/cache_metadatas_arr.json', cache_metadatas_sml_arr)

    print("Copying images")
    copy_imgs_to_3x(img_meta_ranked_only)
    print("We did it lads !")


def eth_native_and_erc20(coins: List[Dict[str, any]]) -> List[Dict[str, any]]:
    def include(coin: dict) -> bool:
        if len(coin['platforms']) == 0:
            return coin['id'] == 'ethereum'
        if 'ethereum' in coin['platforms']:
            return len(coin['platforms']['ethereum']) != 0
        return False
    return list(filter(lambda c: include(c), coins))


def create_cache_markets(
    coins: List[Dict[str, any]],
    markets_dict: Dict[str, any]
) -> Dict[str, any]:
    minimized_markets = dict()
    market_keys_to_remove = [
        'id', 'symbol', 'name', 'image', 'high_24h', 'low_24h', 'roi', 'ath'
        'price_change_24h', 'market_cap_change_24h', 'atl_change_percentage',
        'market_cap_change_percentage_24h', 'max_supply', 'last_updated', 'atl',
        'price_change_percentage_24h_in_currency', 'ath_change_percentage',
        'ath_date', 'atl_date', 'ath', 'price_change_24h'
    ]
    for coin in coins:
        id = coin['coinGeckoId']
        if id in markets_dict:
            market = copy.deepcopy(markets_dict[id])
            for key in market_keys_to_remove:
                market.pop(key, None)
            minimized_markets[id] = market

    return minimized_markets


def create_cache_markets_arr(
    coins: List[Dict[str, any]],
    markets_dict: Dict[str, any]
) -> Dict[str, any]:
    minimized_markets = dict()
    keys = [
        'current_price', 'market_cap', 'market_cap_rank',
        'fully_diluted_valuation', 'total_volume',
        'price_change_percentage_24h', 'circulating_supply', 'total_supply',
    ]
    for coin in coins:
        id = coin['coinGeckoId']
        if id in markets_dict:
            md = markets_dict[id]
            minimized_markets[id] = list(map(lambda x: md.get(x), keys))

    return minimized_markets


def transform_to_markets_dict(markets: List[Dict[str, any]]) -> Dict[str, any]:
    mdict = dict()
    for market in markets:
        mdict[market['id']] = market
    return mdict


def create_cache_currencies(coins: List[Dict[str, any]]) -> List[Dict[str, any]]:
    for coin in coins:
        id = coin['coinGeckoId']
        info = read_json_file('data/coin/' + id + '.json')
        if 'platforms' in coin:
            coin.pop('platforms', None)

        if id not in native_coins:

            if 'platforms' in info and len(info['platforms']) != 0:
                coin['address'] = info['platforms']['ethereum']

            if 'detail_platforms' in info:
                decimals = info['detail_platforms']['ethereum']['decimal_place']
                if decimals != 18:
                    coin['decimals'] = decimals
    return coins


def cache_currencies_arrs(coins: List[Dict[str, any]]) -> List[List[any]]:
    min_coins = list()
    for coin in coins:
        mcoin = [coin['symbol'], coin['name'], coin['coinGeckoId']]
        if 'address' in coin:
            mcoin.append(coin['address'])
        if 'decimals' in coin:
            mcoin.append(coin['decimals'])
        min_coins.append(mcoin)
    return min_coins


def missing_key(coin: Dict[str, any]) -> bool:
    keys =['type', 'address', 'decimals']
    for key in keys:
        if key not in coin:
            return True
    return False


def create_cache_metadatas(
        coins: List[Dict[str, any]],
        small: bool = False
) -> Dict[str, any]:
    metadatas = dict()
    overrides = read_json_file('data/overrides/overrides.json')
    for idx, coin in enumerate(coins):
        meta = dict()
        id = coin['coinGeckoId']
        info = read_json_file('data/coin/' + id + '.json')

        val = val_at_path(['image', 'large'], info)
        if val is not None:
            meta['imageUrl'] = val

        rank = val_at_path(['market_data', 'market_cap_rank'], info)
        if val is not None:
            meta['rank'] = rank

        val = color_for(id, meta['imageUrl'], overrides)
        # val = ['#FF00FF', '#FF00FF']
        if val is not None:
            meta['colors'] = val

        print_progress('Colors ' + id, idx, len(coins))

        if not small:
            val = val_at_path(['links', 'homepage'], info)
            if val is not None:
                meta['link'] = val[0]

            val = val_at_path(['description', 'en'], info)
            if val is not None:
                meta['description'] = val

        metadatas[id] = meta

    return metadatas


def create_cache_metadatas_arrs(
    metadata: Dict[str, any],
    small: bool = False
) -> Dict[str, any]:
    arr_dict = dict()
    arr_keys = ['imageUrl', 'rank', 'colors', 'link']
    if not small:
        # arr_keys.append('link')
        arr_keys.append('description')

    for key, meta_dict in metadata.items():
        arr_dict[key] = list(map(lambda x: meta_dict.get(x), arr_keys))

    return arr_dict


def val_at_path(path: List[str], info: Dict[str, any]) -> any:
    curr_info = info
    for key in path:
        if key in curr_info:
            curr_info = curr_info[key]
        else:
            return None
    return curr_info


def rename_known_bad_img_names():
    base_path = 'data/image/'
    for key in bad_img_names:
        if os.path.isfile(base_path + key):
            os.rename(base_path + key, base_path + bad_img_names[key])
    for key in bad_img_to_remove:
        if os.path.isfile(base_path + key):
            os.remove(base_path + key)


def apply_override_images():
    overrides_base_path = 'data/overrides/images/'
    base_path = 'data/image/'
    imgs = os.listdir(overrides_base_path)
    for img in imgs:
        os.remove(base_path + img)
        shutil.copyfile(overrides_base_path + img, base_path + img)


def resize_images():
    img_lenght = 32 * 3
    base_path = 'data/image/'
    count = len(os.listdir(base_path))
    failed_load_imgs = list()
    failed_resize_imgs = list()

    for idx, img_name in enumerate(os.listdir(base_path)):
        path = base_path + img_name
        image = None
        try:
            image = Image.open(path)
        except:
            failed_load_imgs.append(path)
            os.remove(path)
            print_progress("Removing image " + img_name, idx, count, True)

        if image is not None:
            if image.size[0] != img_lenght or image.size[1] != img_lenght:
                image = image.resize((img_lenght, img_lenght), reducing_gap=3.0)
                try:
                    image.save(path)
                except:
                    failed_resize_imgs.append(path)
        print_progress("Resizing image " + img_name, idx, count)

    print('')
    print('Failed load count', len(failed_load_imgs))
    for failed_path in failed_load_imgs:
        print(failed_path)
    print('Failed resize count', len(failed_resize_imgs))
    for failed_path in failed_resize_imgs:
        print(failed_path)


def change_id_to_coingecko(coins: List[Dict[str, any]]) -> List[Dict[str, any]]:
    for coin in coins:
        coin['coinGeckoId'] = coin['id']
        coin.pop('id', None)
    return coins


def sort_by_rank(
    coins: List[Dict[str, any]],
    markets_dict: Dict[str, any]
) -> List[Dict[str, any]]:
    coins_ranked = list()
    coins_no_rank = list()

    for coin in coins:
        id = coin['coinGeckoId']
        if id in markets_dict:
            market = markets_dict[id]
            if 'market_cap_rank' in market:
                coin['rank'] = market['market_cap_rank']

    for coin in coins:
        if 'rank' in coin and coin['rank'] is not None:
            coins_ranked.append(coin)
        else:
            coins_no_rank.append(coin)

    sorted_coins = list(sorted(coins_ranked, key=lambda x: x['rank']))
    for coin in coins:
        coin.pop('rank', None)

    return sorted_coins + coins_no_rank


def ranked_only_coins(
    coins: List[Dict[str, any]],
    markets_dict: Dict[str, any]
) -> List[Dict[str, any]]:
    coins_ranked = list()

    for coin in coins:
        id = coin['coinGeckoId']
        if id in markets_dict:
            market = markets_dict[id]
            if 'market_cap_rank' in market:
                coin['rank'] = market['market_cap_rank']

    for coin in coins:
        if 'rank' in coin and coin['rank'] is not None:
            coins_ranked.append(coin)

    sorted_coins = list(sorted(coins_ranked, key=lambda x: x['rank']))
    for coin in coins:
        coin.pop('rank', None)

    return sorted_coins


def img_metas(
    coins: List[Dict[str, any]],
    markets_dict: Dict[str, any]
) -> List[ImgMeta]:
    metas = list()
    for coin in coins:
        id = coin['coinGeckoId']
        if id in markets_dict:
            market = markets_dict[id]
            if 'image' in market and market['image'] != 'missing_large.png':
                metas.append(ImgMeta(coin['coinGeckoId'], market['image']))
    return metas


def rgba_to_hex(r, g, b, a):
  return '#{:02X}{:02X}{:02X}{:02X}'.format(r, g, b, a)


def rgb_to_hex(r, g, b) -> str:
  return '#{:02X}{:02X}{:02X}'.format(r, g, b)


class Color:
    def __init__(self, rgba):
        self.rgba = rgba
        self.hex = rgb_to_hex(rgba[0], rgba[1], rgba[2])
        self.average = (rgba[0] + rgba[1] + rgba[2]) / 3


def dominant_colors(image: Image):
    # PIL image input
    ar = np.asarray(image)
    shape = ar.shape
    ar = ar.reshape(np.product(shape[:2]), shape[2]).astype(float)

    kmeans = sklearn.cluster.MiniBatchKMeans(
        n_clusters=10, init="k-means++", max_iter=20, random_state=1000
    ).fit(ar)
    codes = kmeans.cluster_centers_

    vecs, _dist = scipy.cluster.vq.vq(ar, codes)      # assign codes
    counts, _bins = np.histogram(vecs, len(codes))    # count occurrences

    colors = []
    for index in np.argsort(counts)[::-1]:
        colors.append(tuple([int(code) for code in codes[index]]))
    return colors   # returns colors in order of dominance


def color_for(id: str, url: str, overrides: Dict[str, any]) -> List[str]:
    if id in overrides:
        return overrides[id]
    if id is None or url is None:
        return None
    image_name = image_file_name(id, url)
    if image_name in bad_img_names:
        image_name = bad_img_names[image_name]
    if image_name in bad_img_to_remove:
        return None
    image_path = 'data/image/' + image_name
    try:
        image = Image.open(image_path).convert("RGBA")
        with warnings.catch_warnings():
            warnings.filterwarnings("ignore")
            colors_rgba = dominant_colors(image)
            colors = map(lambda rgba: Color(rgba), colors_rgba)
            colors = filter(
                lambda color: color.average != 0 and color.average != 255,
                colors
            )
            colors = sorted(colors, key=lambda x: x.average)
            if len(colors) > 0:
                return [
                    colors[int(len(colors) * 0.33)].hex,
                    colors[int(len(colors) * 0.66)].hex
                ]
            else:
                return None
    except:
        return None


def copy_imgs_to_3x(metas: List[ImgMeta]):
    for  meta in metas:
        id = meta.id
        url = meta.url
        if id is None or url is None:
            continue
        image_name = image_file_name(id, url)
        if image_name in bad_img_names:
            image_name = bad_img_names[image_name]
        if image_name in bad_img_to_remove:
            continue
        parts = image_name.split('.')
        file_extension = parts[1]

        for ext in ['.PNG', '.JPG', '.JPEG']:
            file_extension = file_extension.replace(ext, ext.lower())

        shutil.copyfile(
            'data/image/' + image_name,
            'data/@3x/' + parts[0] + '@3x.' + file_extension
        )


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    main()
