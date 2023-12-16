from enum import Enum

from coin_checko_api import CoinGeckoAPI
from typing import List, Dict
import json
import pandas as pd
import os
from utils import write_json_file, print_progress
from urllib.parse import urljoin, urlparse
from dataclasses import dataclass


@dataclass
class ImgMeta():
    id: str
    url: str


def download_image(
    img_meta: List[ImgMeta],
    api: CoinGeckoAPI,
    skip_if_exists: bool = False
):
    ids_cnt = len(img_meta)
    for idx, img_meta in enumerate(img_meta):
        name = image_file_name(img_meta.id, img_meta.url)
        path = 'data/image/' + name
        print_progress("Downloading image " + img_meta.id, idx, ids_cnt)
        if skip_if_exists and os.path.isfile(path):
            continue
        data = download_image_data(img_meta.url, api)
        if data is not None:
            with open(path, 'wb') as f:
                f.write(data)


def download_image_data(
    url: str,
    api: CoinGeckoAPI
) -> bytes:
    response = api.fetch_content(url)
    return None if response is None else response


def file_name_for_url(url: str) -> str:
    return urljoin(url, urlparse(url).path).rsplit('/', 1)[-1]


def file_extension_for_url(url: str) -> str:
    return os.path.splitext(file_name_for_url(url))[-1]


def image_file_name(id: str, url: str) -> str:
    return id + file_extension_for_url(url)