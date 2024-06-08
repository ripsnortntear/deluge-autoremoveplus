#!/usr/bin/env python3.6

import os
import sys
import logging

def get_config():
    config = {}
    config_file = os.path.join(os.path.dirname(__file__), 'config.json')
    if os.path.exists(config_file):
        with open(config_file, 'r') as f:
            config = json.load(f)
    return config

def setup_logging(log_file, log_level):
    logger = logging.getLogger('autoremoveplus')
    logger.setLevel(log_level)
    handler = logging.FileHandler(log_file)
    handler.setFormatter(logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
    logger.addHandler(handler)

def print_exception(e):
    print("Error: {}".format(e))

def main():
    config = get_config()
    log_file = os.path.join(os.path.dirname(__file__), 'autoremoveplus.log')
    setup_logging(log_file, logging.DEBUG)

if __name__ == '__main__':
    main()
