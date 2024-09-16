import asyncio
import httpx

sentences = [
    "Saya suka makan nasi goreng.",
    "Hari ini cuaca sangat panas.",
    "Anjing itu sangat lucu.",
    "Kami akan pergi ke pantai besok.",
    "Apakah kamu punya hobi?",
    "Buku ini sangat menarik untuk dibaca.",
    "Sekarang waktunya istirahat.",
    "Kucing itu tidur di bawah meja.",
    "Makanan favorit saya adalah rendang.",
    "Kami berencana untuk berlibur ke Bali.",
]

api_url = "http://api:6000/predict"

async def send_request(aclient, sentence):
    try:
        response = await aclient.post(api_url, params={"text": sentence})
        response.raise_for_status()
        print(response.json())
    except Exception as e:
        print(e)

async def main():
    async with httpx.AsyncClient() as aclient:
        await asyncio.sleep(5)  # add a delay of 5 seconds before start sending requests
        for sentence in sentences:
            await send_request(aclient, sentence)
            await asyncio.sleep(1)  # add a delay of 1 second

if __name__ == "__main__":
    asyncio.run(main())