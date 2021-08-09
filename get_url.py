#!/usr/bin/env python

import re
import sys
import requests
import natsort

from operator import attrgetter, itemgetter
from bs4 import BeautifulSoup

def write_out(filename, content, mode="w"):
    """File.write convenience wrapper."""
    with open_auto(filename, mode) as require_f:
        require_f.write(content)

def open_auto(*args, **kwargs):
    """Open a file with UTF-8 encoding.

    Open file with UTF-8 encoding and "surrogate" escape characters that are
    not valid UTF-8 to avoid data corruption.
    """
    # 'encoding' and 'errors' are fourth and fifth positional arguments, so
    # restrict the args tuple to (file, mode, buffering) at most
    assert len(args) <= 3
    assert "encoding" not in kwargs
    assert "errors" not in kwargs
    return open(*args, encoding="utf-8", errors="surrogateescape", **kwargs)

soup = BeautifulSoup(requests.get("https://forums.insynchq.com/c/releases/15").text, "html5lib")
thread_list = soup.find_all("tr", attrs={"class": "topic-list-item"})

thread_version_re = re.compile(r"(?:Insync version:\s|Insync version\s)((?:\d+)(?:[-._]*\d+)*)")
thread_version_sort = []
for thread in thread_list:
    thread_title = thread.find("a", attrs={"class": "title"})
    thread_version_match = thread_version_re.search(thread_title.text)
    if thread_version_match:
        thread_version_sort.append(list([f"{thread_version_match.group(1)}", f"{thread_title.get('href')}"]))

if not thread_version_sort:
    print("Can't find thread")
    sys.exit(1)

thread_version_sort = natsort.natsorted(thread_version_sort, key=itemgetter(0))

#for thread in thread_version_sort:
    #print(thread)
#print(f"Last: {thread_version_sort[-1][0]} - {thread_version_sort[-1][1]}")

thread_version_html = BeautifulSoup(requests.get(thread_version_sort[-1][1]).text, "html5lib")
thread_version_top_post = thread_version_html.find("div", attrs={"class": "topic-body"})
thread_version_top_post_links = thread_version_top_post.find_all("a")

get_url_fc_rpm_re = re.compile(r".*(?:-fc3\d{1}.x86_64.rpm)")
get_urlfc_rpm_replace_re = re.compile(r"fc3\d")
found_url = ""
for link in thread_version_top_post_links:
    get_url_fc_rpm_match = get_url_fc_rpm_re.search(link.get('href'))
    if get_url_fc_rpm_match:
        #print(get_url_fc_rpm_match.group(0))
        found_url = re.sub(get_urlfc_rpm_replace_re, "fc34", get_url_fc_rpm_match.group(0))

if found_url:
    print(f"{found_url} {thread_version_sort[-1][0]}")
    sys.exit(0)
else:
    print("Can't find download link in thread")
    sys.exit(1)
