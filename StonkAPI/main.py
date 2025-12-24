from fastapi import FastAPI, Response
import yfinance as yf
import json, requests, os
from dotenv import load_dotenv

app = FastAPI()
load_dotenv()

@app.get("/tickers/{ticker}")
async def getTicker(ticker: str):
    tickerObject = yf.Ticker(ticker)
    price = tickerObject.fast_info.last_price

    return {"price": price}

@app.get("/logos/{ticker}")
async def getLogo(ticker: str):
    url = f"https://img.logo.dev/ticker/{ticker}?token={os.getenv("LOGO_API_KEY")}"
    response = requests.get(url)
    return Response(response.content, media_type="image/png")