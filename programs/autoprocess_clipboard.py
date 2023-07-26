#!/usr/bin/env python

"""
This reads input from stdin, and if it pattern-matches an AWS account ID,
looks if it knows that account ID and sends a notification containing
the corresponding account name.

The use-case is to connect it to the clipboard. You can then select an AWS
account ID with the mouse and will receive a notification telling you
the account name.
In wayland this can be achived like this:
`wl-paste --primary --watch ./process_clipboard.py`
"""

import re
import json
import sys
import pathlib
import subprocess

contents = sys.stdin.read()
processed = contents.replace('-', '')

if re.match(r"\d{12}", processed):
    # aws-accounts.json is created with `mkdir -p ~/.cache/autoprocess_clipboard && aws organizations list-accounts > ~/.cache/autoprocess_clipboard/aws-accounts.json`
    with open(pathlib.Path('~/.cache/autoprocess_clipboard/aws-accounts.json').expanduser(), encoding='utf8') as fh:
        accounts = json.load(fh)
    for account in accounts["Accounts"]:
        if account["Id"] == processed:
            subprocess.run(["notify-send", f"{account['Id']}: {account['Name']}"], check=True)
