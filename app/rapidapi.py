import requests
from dotenv import get_key

class RAPIDAPI:
    def __init__(self):
        self.RAPID_API_URL = 'https://local-business-data.p.rapidapi.com'
        self.X_RAPIDAPI_HOST = 'local-business-data.p.rapidapi.com'
        self.X_RAPIDAPI_KEY = get_key("../.env", "X_RAPIDAPI_KEY")
    
    def search (
        self,
        query_string: str,
        limit: int,
        lat: float,
        lng: float,
        zoom: float,
        language: str,
        region: str,
        extract_emails_and_contacts: bool
    ) -> object:
        
        url = self.RAPID_API_URL + "/search"
        
        params = {
            "query": query_string,
            "limit": limit,
            "lat": lat,
            "lng": lng,
            "zoom": zoom,
            "language": language,
            "region": region,
            "extract_emails_and_contacts": extract_emails_and_contacts
        }

        headers = {
            "x-rapidapi-host": self.X_RAPIDAPI_HOST,
            "x-rapidapi-key": self.X_RAPIDAPI_KEY
        }

        response = requests.get(url, params=params, headers=headers)

        return response.json()


    def test_search() -> object:
        api = RAPIDAPI()
        result = api.search(
            query_string="кавʼярня",
            limit=1,
            lat=50.4689019516804,
            lng=30.512872309003477,
            zoom=12,
            language="ua",
            region="UA",
            extract_emails_and_contacts=True
        )
        print(get_key("../.env", "X_RAPIDAPI_KEY"))
        return result