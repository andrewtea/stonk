from fastapi import FastAPI, Response
import yfinance as yf
import json, requests, os
from dotenv import load_dotenv

app = FastAPI()
load_dotenv()

@app.get("/prices/{ticker}")
async def getTicker(ticker: str):
    tickerObject = yf.Ticker(ticker)
    price = tickerObject.fast_info.last_price

    return {"price": price}

@app.get("/logos/{ticker}")
async def getLogo(ticker: str):
    url = f"https://img.logo.dev/ticker/{ticker}?token={os.getenv("LOGO_API_KEY")}"
    response = requests.get(url)
    return Response(response.content, media_type="image/png")

@app.get("/history/{ticker}")
async def getHistory(ticker: str, period: str = "1mo"):
    tickerObject = yf.Ticker(ticker)

    # Map period to yfinance parameters (period, interval)
    period_map = {
        "1d": ("1d", "15m"),      # 1 day, hourly intervals
        "1w": ("5d", "1d"),      # 5 trading days, daily
        "1mo": ("1mo", "1d"),    # 1 month, daily
        "1y": ("1y", "1wk"),     # 1 year, weekly
        "5y": ("5y", "1mo")      # 5 years, monthly
    }

    yf_period, interval = period_map.get(period, ("1mo", "1d"))
    history = tickerObject.history(period=yf_period, interval=interval)

    data = []
    for date, row in history.iterrows():
        data.append({
            "date": date.isoformat(),
            "close": row["Close"]
        })

    return {"history": data}


@app.get("/info/{ticker}")
async def getInfo(ticker: str):
    tickerObject = yf.Ticker(ticker)
    info = tickerObject.info

    return {
        "name": info.get("longName"),
        "description": info.get("longBusinessSummary"),
        "sector": info.get("sector"),
        "website": info.get("website"),
        "marketCap": info.get("marketCap"),
        "peRatio": info.get("trailingPE"),
        "dividendYield": info.get("dividendYield"),
        "beta": info.get("beta"),
        "fiftyTwoWeekHigh": info.get("fiftyTwoWeekHigh"),
        "fiftyTwoWeekLow": info.get("fiftyTwoWeekLow"),
        "previousClose": info.get("previousClose"),
        "averageVolume": info.get("averageVolume"),
        "industry": info.get("industry"),
        "country": info.get("country"),
        "employees": info.get("fullTimeEmployees")
    }