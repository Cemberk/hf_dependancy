#clear_cache_plugin.py

import os
import shutil
import pytest

def pytest_addoption(parser):
    parser.addoption("--clear-cache-interval", action="store", default=10, type=int, help="Interval for clearing cache")

def pytest_configure(config):
    config.cache_clear_counter = 0
    config.cache_clear_interval = config.getoption("--clear-cache-interval")

def pytest_runtest_teardown(item, nextitem):
    item.config.cache_clear_counter += 1
    if item.config.cache_clear_counter >= item.config.cache_clear_interval:
        clear_cache()
        item.config.cache_clear_counter = 0

def clear_cache():
    cache_dir = ".pytest_cache"  # Replace with your cache directory
    if os.path.exists(cache_dir):
        shutil.rmtree(cache_dir)
        print("Cache cleared")

