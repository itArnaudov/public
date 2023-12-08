import requests
import json
from datetime import datetime

# Set your Azure AD tenant ID, client ID, client secret, and other parameters
tenant_id = 'your_tenant_id'
client_id = 'your_client_id'
client_secret = 'your_client_secret'
token_endpoint = f'https://login.microsoftonline.com/{tenant_id}/oauth2/v2.0/token'
graph_endpoint = 'https://graph.microsoft.com/v1.0/'

# Function to get an access token
def get_access_token():
    token_data = {
        'grant_type': 'client_credentials',
        'client_id': client_id,
        'client_secret': client_secret,
        'scope': 'https://graph.microsoft.com/.default'
    }
    token_response = requests.post(token_endpoint, data=token_data)
    token_json = token_response.json()
    return token_json.get('access_token')

# Function to get users and their password policies
def get_users_and_password_reset_dates(access_token):
    headers = {
        'Authorization': 'Bearer ' + access_token,
        'Content-Type': 'application/json'
    }

    # Request users and include passwordPolicies property
    users_url = graph_endpoint + 'users?$select=id,userPrincipalName,passwordPolicies'
    response = requests.get(users_url, headers=headers)
    users_data = response.json().get('value', [])

    # Process user data
    for user in users_data:
        user_id = user.get('id')
        user_principal_name = user.get('userPrincipalName')
        password_policies = user.get('passwordPolicies', [])

        # Check if the user has a password policy set
        if 'DisablePasswordExpiration' in password_policies:
            print(f"User: {user_principal_name} (ID: {user_id}) - Password does not expire")
        else:
            # Retrieve password profile to get password last changed date
            password_profile_url = graph_endpoint + f'users/{user_id}/?$select=passwordProfile'
            password_profile_response = requests.get(password_profile_url, headers=headers)
            password_profile = password_profile_response.json().get('passwordProfile', {})

            # Extract the password last changed date
            password_last_changed = password_profile.get('passwordLastChangedDateTime')

            if password_last_changed:
                # Convert the date to a more readable format
                password_last_changed_date = datetime.strptime(password_last_changed, '%Y-%m-%dT%H:%M:%S.%fZ')
                print(f"User: {user_principal_name} (ID: {user_id}) - Password last changed: {password_last_changed_date}")
            else:
                print(f"User: {user_principal_name} (ID: {user_id}) - Unable to retrieve password last changed date")

if __name__ == "__main__":
    access_token = get_access_token()
    if access_token:
        get_users_and_password_reset_dates(access_token)
    else:
        print("Unable to obtain access token.")
#