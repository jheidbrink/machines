#!/usr/bin/env python

"""
Sync repos defined in ~/.config/sync_repos.json

TODO:
* warn when encountering unknown remotes, add missing remotes
* think about error handling
* offline mode
* different intervals
* Just fetch, merge and push all defined remotes?
  - but then I couldn't use this script for initial clone
"""

import argparse
import json
from dataclasses import dataclass
import logging
from pathlib import Path
import subprocess
import time
from typing import Union, cast

RemoteName = str
RemoteUrl = str

RemoteData = dict[RemoteName, RemoteUrl]
RepoData = dict[str, Union[str, RemoteData]]
StoredConfig = list[RepoData]


def loadconfig() -> StoredConfig:
    logging.debug("Loading repos config from ~/.config/syncrepos.json")
    with Path("~/.config/syncrepos.json").expanduser().open(encoding="utf8") as f:
        return cast(StoredConfig, json.load(f))


@dataclass
class Remote:
    name: str
    url: str

    def __str__(self) -> str:
        return self.name


class Repo:
    def __init__(
        self,
        path: Path,
        remotes: list[Remote],
    ):
        self.path = path
        self.remotes = remotes

    @classmethod
    def from_json(cls, repo_data: RepoData) -> "Repo":
        return cls(
            Path(cast(str, repo_data["path"])),
            [Remote(name, url) for name, url in cast(RemoteData, repo_data["remotes"]).items()],
        )

    def __str__(self):
        return f"Git repository {self.path}"

    def ensure_exists(self):
        if not self.path.exists():
            logging.warning("Path %s does not exist, cloning repository", self.path)
            self.path.parent.mkdir(parents=True, exist_ok=True)
            subprocess.run(["git", "clone", '--origin', self.remotes[0].name, self.remotes[0].url, self.path.name], cwd=self.path.parent, check=True)
            for remote in self.remotes[1:]:
                subprocess.run(["git", "remote", "add", remote.name, remote.url], cwd=self.path, check=True)

    def _fetch(self, remote: Remote):
        logging.debug("Running git fetch %s in %s", remote, self.path)
        subprocess.run(["git", "fetch", str(remote)], cwd=self.path, check=True)

    def fetch_all(self):
        for remote in self.remotes:
            try:
                self._fetch(remote)
            except subprocess.CalledProcessError:
                logging.warning("%s: Fetching from remote %s failed", self, remote)

    # TODO: merge_all. idea: check all remote branches that contain our HEAD
    def merge(self):
        logging.debug("Running git merge --ff-only in %s", self.path)
        subprocess.run(["git", "merge", "--ff-only"], cwd=self.path, check=True)

    def push_all(self):
        for remote in self.remotes:
            try:
                self._push(remote)
            except subprocess.CalledProcessError:
                logging.warning("%s: Pushing to remote %s failed", self, remote)

    def _push(self, remote: Remote):
        logging.debug("running git push %s in %s", remote, self.path)
        subprocess.run(["git", "push", str(remote)], cwd=self.path, check=True)

    def sync(self):
        self.ensure_exists()
        self.fetch_all()
        self.merge()
        self.push_all()


def load_repos() -> list[Repo]:
    return [Repo.from_json(repo_data) for repo_data in loadconfig()]


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--oneshot", action="store_true", default=False)
    return parser.parse_args()


def main():
    logging.basicConfig(level=logging.DEBUG)
    args = parse_args()
    repos = load_repos()

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
