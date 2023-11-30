import requests

def search_google(query, api_key, cse_id):
    url = 'https://www.googleapis.com/customsearch/v1'
    params = {
        'key': api_key,
        'cx': cse_id,
        'q': query
    }
    response = requests.get(url, params=params)
    return response.json()

# Example usage
api_key = 'AIzaSyCjHKEA3XvtQSyzsrQnSjiPw8ayuJTThKs'
cse_id = 'd1d5c436170d94154'
query = 'B0015 terminator'

results = search_google(query, api_key, cse_id)
print(results)

