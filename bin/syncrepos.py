#!/usr/bin/env python

"""
Sync repos defined in ~/.config/sync_repos.json

TODO:
* think about error handling
* offline mode
* different intervals
* Just fetch, merge and push all defined remotes?
"""

import argparse
import json
import logging
from pathlib import Path
import subprocess
import time
from typing import List, NewType


FetchRemote = NewType("FetchRemote", str)
PushRemote = NewType("PushRemote", str)
MergeRef = NewType("MergeRef", str)


class Repo:
    def __init__(
        self,
        path: str,
        fetch_targets: List[FetchRemote],
        merge_refs: List[MergeRef],
        push_targets: List[PushRemote],
    ):
        self.path = path
        self.fetch_targets = fetch_targets
        self.merge_refs = merge_refs
        self.push_targets = push_targets

    def __str__(self):
        return f"Git repository {self.path}"

    def _fetch(self, fetch_target: FetchRemote):
        logging.debug("Running git fetch %s in %s", fetch_target, self.path)
        subprocess.run(["git", "fetch", fetch_target], cwd=self.path, check=True)

    def fetch_all(self):
        for target in self.fetch_targets:
            try:
                self._fetch(target)
            except subprocess.CalledProcessError:
                time.sleep(1)

    def merge_all(self):
        for ref in self.merge_refs:
            try:
                self._merge(ref)
            except subprocess.CalledProcessError:
                time.sleep(1)

    def _merge(self, merge_ref: MergeRef):
        logging.debug("Running git merge --ff-only %s in %s", merge_ref, self.path)
        if merge_ref:
            subprocess.run(
                ["git", "merge", "--ff-only", merge_ref],
                cwd=self.path,
                check=True,
            )
        else:
            subprocess.run(["git", "merge", "--ff-only"], cwd=self.path, check=True)

    def push_all(self):
        for target in self.push_targets:
            try:
                self._push(target)
            except subprocess.CalledProcessError:
                time.sleep(1)

    def _push(self, push_target: PushRemote):
        logging.debug("running git push %s in %s", push_target, self.path)
        subprocess.run(["git", "push", push_target], cwd=self.path, check=True)

    def sync(self):
        self.fetch_all()
        self.merge_all()
        self.push_all()


def load_repos_config() -> List[Repo]:
    logging.debug("Loading repos config from ~/.config/syncrepos.json")
    with Path("~/.config/syncrepos.json").expanduser().open(encoding="utf8") as f:
        repos_config = json.load(f)
    return [
        Repo(
            item["path"],
            [FetchRemote(ii) for ii in item["fetch_remotes"]],
            [MergeRef(ii) for ii in item["merge_refs"]],
            [PushRemote(ii) for ii in item["push_remotes"]],
        )
        for item in repos_config
    ]


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--oneshot", action="store_true", default=False)
    return parser.parse_args()


def main():
    logging.basicConfig(level=logging.DEBUG)
    args = parse_args()
    repos = load_repos_config()

    def sync_all_repos():
        for repo in repos:
            logging.debug("Syncing %s", repo)
            repo.sync()

    if args.oneshot:
        sync_all_repos()
        return

    while True:
        logging.debug("New loop")
        sync_all_repos()
        logging.debug("Sleeping 5 minutes")
        time.sleep(300)


if __name__ == "__main__":
    main()
