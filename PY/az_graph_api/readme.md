# Azure AD Graph API - User Password Reset Dates

This Python script demonstrates how to use the Microsoft Graph API to retrieve Azure AD user information, including their password reset dates. The script checks if a user's password expires and, if applicable, provides the date when the password was last changed.

## Prerequisites

1. **Azure AD App Registration:**
    - Before running the script, you need to register an application in Azure AD.
    - Follow the steps below to create an app registration.

2. **Python Environment:**
    - Make sure you have Python installed on your machine.

## Azure AD App Registration Steps

1. **Go to Azure Portal:**
   - Log in to the [Azure portal](https://portal.azure.com/).

2. **Navigate to Azure AD:**
   - In the left sidebar, click on "Azure Active Directory."

3. **Register an Application:**
   - Go to "App registrations" and click on "New registration."
   - Fill in the required information:
        - Name: Enter a name for your application.
        - Supported account types: Choose the appropriate option.
        - Redirect URI: Choose the appropriate option or leave it blank for now.
   - Click on "Register."

4. **Generate Client Secret:**
   - In the left sidebar, go to "Certificates & Secrets."
   - Under "Client secrets," click on "New client secret."
   - Enter a description, choose an expiration, and click on "Add."
   - Copy the generated secret value - you'll need it later.

5. **Add API Permissions:**
   - In the left sidebar, go to "API permissions."
   - Click on "Add a permission" and select "Microsoft Graph."
   - Choose the appropriate permissions (e.g., `User.Read.All`, `Directory.Read.All`).
   - Click on "Add permissions" and grant admin consent if required.

6. **Note Application (Client) ID:**
   - In the "Overview" section, note down the "Application (client) ID" - you'll need it later.

7. **Note Directory (Tenant) ID:**
   - In the "Overview" section, note down the "Directory (tenant) ID" - you'll need it later.

## Running the Script

1. **Clone the Repository:**
    ```bash
    git clone https://github.com/itArnaudov/public.git
    cd azure-ad-graph-api
    ```

2. **Install Dependencies:**
    ```bash
    pip install requests
    ```

3. **Update Configuration:**
    - Open the script (`graph_api_script.py`) in a text editor.
    - Replace the placeholder values with the information from your Azure AD app registration:
        - `tenant_id`
        - `client_id`
        - `client_secret`

4. **Run the Script:**
    ```bash
    python graph_api_script.py
    ```

5. **View Results:**
    - The script will display user information, including password expiration details.

## Notes

- Ensure that the Azure AD app registration has the necessary permissions (e.g., `User.Read.All`, `Directory.Read.All`).
- Admin consent may be required for some permissions.

## License

This project is licensed under the [MIT License](LICENSE).
