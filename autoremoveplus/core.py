#!/usr/bin/env python3.6

import os
import sys
import json
import xmlrpc.client
import socket
import time
import threading
import logging

class AutoremovePlusCore:
    def __init__(self, config, logger):
        self.config = config
        self.logger = logger
        self.deluge_rpc = xmlrpc.client.ServerProxy('http://localhost:8112')
        self.torrents = {}

    def connect_to_deluge(self):
        try:
            self.deluge_rpc.auth.login(self.config['deluge']['username'], self.config['deluge']['password'])
            self.logger.info("Connected to Deluge")
        except xmlrpc.client.Fault as e:
            self.logger.error("Failed to connect to Deluge: %s", e)
            return False
        return True

    def get_torrents(self):
        try:
            torrents = self.deluge_rpc.core.get_torrents_status({}, ["name", "total_size", "ratio", "state"])
            for torrent in torrents:
                self.torrents[torrent["name"]] = torrent
            self.logger.info("Fetched %d torrents from Deluge", len(torrents))
        except xmlrpc.client.Fault as e:
            self.logger.error("Failed to fetch torrents from Deluge: %s", e)

    def remove_torrent(self, torrent_name):
        try:
            self.deluge_rpc.core.remove_torrent(torrent_name)
            self.logger.info("Removed torrent %s from Deluge", torrent_name)
        except xmlrpc.client.Fault as e:
            self.logger.error("Failed to remove torrent %s from Deluge: %s", torrent_name, e)

    def pause_torrent(self, torrent_name):
        try:
            self.deluge_rpc.core.pause_torrent(torrent_name)
            self.logger.info("Paused torrent %s in Deluge", torrent_name)
        except xmlrpc.client.Fault as e:
            self.logger.error("Failed to pause torrent %s in Deluge: %s", torrent_name, e)

    def resume_torrent(self, torrent_name):
        try:
            self.deluge_rpc.core.resume_torrent(torrent_name)
            self.logger.info("Resumed torrent %s in Deluge", torrent_name)
        except xmlrpc.client.Fault as e:
            self.logger.error("Failed to resume torrent %s in Deluge: %s", torrent_name, e)

def main():
    config = {'deluge': {'username': 'deluge', 'password': 'deluge'}}
    logger = logging.getLogger('autoremoveplus')
    logger.setLevel(logging.DEBUG)
    handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
    logger.addHandler(handler)

    core = AutoremovePlusCore(config, logger)
    if core.connect_to_deluge():
        core.get_torrents()
        # TO DO: implement autoremove logic
    else:
        logger.error("Failed to connect to Deluge")

if __name__ == '__main__':
    main()
