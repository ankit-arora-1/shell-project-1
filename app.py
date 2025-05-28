from fastapi import FastAPI, HTTPException
import random

app = FastAPI()

@app.get("/")
async def root():
    # Randomly return 500 error for testing
    if random.random() < 0.1:  # 10% chance
        raise HTTPException(status_code=500, detail="Simulated server error")
    return {"message": "Hello from FastAPI"}

@app.get("/error")
async def error():
    raise HTTPException(status_code=500, detail="Intentional error for testing")
