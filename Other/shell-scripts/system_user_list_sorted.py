#!/usr/bin/env python3
import subprocess
import csv
from collections import defaultdict

# Run getent passwd and capture the output
passwd_output = subprocess.check_output(['getent', 'passwd']).decode('utf-8')

# Parse entries into list of tuples (UserName, UID)
entries = []
uid_count = defaultdict(int)

for line in passwd_output.strip().split('\n'):
    parts = line.split(':')
    if len(parts) >= 3:
        username = parts[0]
        uid = int(parts[2])
        entries.append((username, uid))
        uid_count[uid] += 1

# Sort by UID
entries.sort(key=lambda x: x[1])

# Write CSV
with open('users.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(['UID', 'UserName', 'DuplicateUID'])
    for username, uid in entries:
        is_duplicate = 'Yes' if uid_count[uid] > 1 else ''
        writer.writerow([uid, username, is_duplicate])

print("users.csv written.")

