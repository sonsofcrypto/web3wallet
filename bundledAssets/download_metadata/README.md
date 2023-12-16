# Pump Respectooor
<img src="pump_respectoor_v2.png"/>

Analyzing the frequency of pumps of coins listed on [Coin Gecko](https://www.coingecko.com/).

## Usage 
Coin Gecko has `coins/${ID}/chart range` api that returns historical daily close
price alongside volume. These cross day pumps are analyzed in 
`analysis_chart.ipynb` [jupyter lab notebook](https://jupyter.org/install).

However, a lot of the pumps happen within single data. open to high price. 
`coins/${ID}/ohlc` endpoint provides timestamped daily candle. But without a 
volume. `analysis_chart.ipynb` combines chart and ohlc data together and 
finds all pumps. Plots the data and saves it to `results` folder.

### Download data

To download data run `main.py`. Make sure to comment out data you don't want to    
download. __Some endpoints are only available with paid API key__ (daily ohlc).
There are three download modes. See `api = CoinGeckoAPI(ExecPolicy.API_KEY)` in 
`main.py`
- __SLEEP__ Simply sleeps when requests limit per minute is reached. Takes days 
  to download all data. 

- __VPN__ Switches to different openVPN profile when free API limit is reached. 
  In thoery it should work with any open VPN profile. Was only tested  with 
  proton mail VPN. You can create free [protonmail](proton.me) account and 
  download profiles at [OpenVpnIKEv2 profiles](https://account.proton.me/u/0/vpn/OpenVpnIKEv2) Needs `.env` 
  `VPN_USER=${YOUR_USER}` & `VPN_PASS=${YOUR_PASS}` and profiles in 
  `vpn_switcher/profiles`. Has to be run with root privileges to switch VPN. 
  Takes just over a day to download all data.

- __API_KEY__ Stays within requests per minute of lowest paid API tier. Download 
  time about ~24h. Needs `COIN_GECKO_API=${YOUR_API_KEY}` in `.env` file.

  
## Results

Detailed results are in cvs files in `/results`. A few highlights.
I've finished pump analyses. I never would have though in this market you've got
2 coins a day, with at least $1mil volume on pump day doing 2x. You've got 8x 
every 4.5 days with $1mil volume. For 1.5x you've got 5.33 coins doing that 
every day with at least $1mil volume on the pump day. These number continue to 
blow my mind. That's out 10k coins on Goin Gecko.

![1.5x](results/1.5x.png)
![2x](results/2x.png)
![4x](results/4x.png)
![8x](results/8x.png)

Here are coins that did 2x with at least $1mil volume on pump day in October 
2023 so far:
```
yocoinyoco, roaland-core, decubate, polaris-share, sundae-the-dog, cryptopawcoin,
zuzuai, pay-coin, blackpearl-chain, equitypay, seiren-games-network, hxacoin, 
mind-matrix, gameai, apes-go-bananas, big-time,  
```

All the results are in `results` folder.

Looking at just cross days pump (more data available). Even in bear market.
Pumps are live and well.

![2x](results/chart_2x.png)


