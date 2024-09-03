import requests
import pandas as pd
import os

def extract_data():
    # URL API
    url = "https://api.travelpayouts.com/v1/prices/calendar"

    querystring = {"depart_date":"2019-11","origin":"MOW","destination":"BCN","calendar_type":"departure_date","currency":"USD"}

    headers = {'x-access-token': '321d6a221f8926b5ec41ae89a3b2ae7b'}

    # Mengambil data dari API
    response = requests.request("GET", url, headers=headers, params=querystring)

    # Mengecek apakah permintaan berhasil
    if response.status_code == 200:
        data = response.json()

        # Mengubah data ke DataFrame
        df = pd.DataFrame(data)

        # Membuat direktori 'data' jika belum ada
        if not os.path.exists('data'):
            os.makedirs('data')

        # Menyimpan DataFrame ke file CSV
        df.to_csv('data/travel.csv', index=False)
    else:
        print(f"Request failed with status code {response.status_code}")

if __name__ == "__main__":
    extract_data()