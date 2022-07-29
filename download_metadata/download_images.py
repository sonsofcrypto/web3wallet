import json
import requests
import time
import shutil
import os
import platform
from urllib.parse import urljoin, urlparse


def fileNameFor(id: str, url: str) -> str:
	name = id + "_large"
	if ".jpg" in url:
		return name + ".jpg"
	elif ".JPG" in url:
		return name + ".JPG"
	elif ".jpeg" in url:
		return name + ".jpeg"
	elif ".png" in url:
		return name + ".png"
	elif ".PNG" in url:
		return name + ".PNG"
	elif ".webp" in url:
		return name + ".webp"
	else:
		return name + ".unknown"


def download_image(file_name: str, url: str):
	res = requests.get(url, stream = True)
	if res.status_code == 200:
		with open(file_name,'wb') as f:
			shutil.copyfileobj(res.raw, f)
			print('Image sucessfully Downloaded: ', file_name)
	else:
		print('Image Couldn\'t be retrieved', res.status_code)


headers = requests.utils.default_headers()
default_agent = headers['User-Agent']

headers.update(
    {
        'User-Agent': default_agent + ' (' + platform.platform() + ')',
    }
)


with open('coin_cache.json', 'r') as file:
    data = file.read()

coins = json.loads(data)
failed_in_row = 0

print("total size", len(coins))
print("======================")

for i in reversed(range(3649, len(coins)-300)):
	coin = coins[i]
	id = coin["id"]
	if "imageURL" not in coin:
		continue
	url = coin["imageURL"]
	# url = urljoin(url, urlparse(url).path)
	if url == None or url == "":
		continue
	fileName = fileNameFor(id, url)
	filePath = 'images/' + fileName
	print(fileName, url)
	res = requests.get(url, headers = headers, stream = True)
	if res.status_code == 200:
		with open(filePath,'wb') as f:
			shutil.copyfileobj(res.raw, f)
			print('Image sucessfully Downloaded: ', fileName)
			failed_in_row = 0
	else:
		failed_in_row += 1
		print('Image Couldn\'t be retrieved', res.status_code)
	if failed_in_row > 5:
		print("Bailing out")
		os.exit(1)
	time.sleep(3.0)

# 654