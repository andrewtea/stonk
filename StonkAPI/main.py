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