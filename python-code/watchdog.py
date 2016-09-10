#!/usr/bin/python
__author__ = 'ravips2394'

import sys
import os
import json
import yaml
import requests
import argparse
import logging
from twython import Twython




# Variables
CONFIG = dict()

# Get list of contributors

def get_list_contributors():
    response = requests.get(CONFIG['github']['contributors_api'])
    contributors_response = json.loads(response.content)
    contributors =[i['login'] for i in contributors_response]
    return contributors


# Write contributors list to FS so that we can preserve the state during the system reboot and we can see the diff as well if there is a new contributor
# introduced to git repo Diff between current list and new list of contributors
# write a logger function which should log if there is checkin by new user
# Notify to twitter if there is checkin by new user
# Need to create a config file
# store the contributors in a json file.
# new contributor events should be logged

def sync_to_local(remote_list):
    with open('contributors.json', 'w+') as f:
        json.dump(remote_list, f)

def logger(text):
    logging.basicConfig(filename=CONFIG['logging_path'],
                filemode='a',
                format=('%(asctime)s %(levelname)s %(message)s'),
                level=logging.DEBUG)
    logging.info(text)

def tweet_at_twitter(text):
    twitter = Twython(CONFIG['twitter']['APP_KEY'], CONFIG['twitter']['APP_SECRET'],CONFIG['twitter']['OAUTH_TOKEN'], CONFIG['twitter']['OAUTH_TOKEN_SECRET'])
    twitter.update_status(status=text)





if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-c', '--config', action='store', dest='config_path', help='Config File Path')
    options = parser.parse_args()
    config_path = options.config_path

    if os.path.exists(config_path):
        with open(config_path, mode='r') as stream:
            try:
                CONFIG = yaml.load(stream)
            except yaml.YAMLError as exc:
                print(exc)

        if os.path.exists(CONFIG['contributors_local_file']):
            with open(CONFIG['contributors_local_file'], 'r') as local_file:
                local_list = json.load(local_file)
                print "local list: %s" %local_list

            remote_list = get_list_contributors()
            sync_to_local(remote_list)
            print "remote list: %s" %remote_list
                #notify_to_channel(res)
            if local_list == remote_list:
                print "There is no change"
            else:
                print "Yes there is a change and we need to notify this"
                #Here as the new contributor will be an addition so remote_list will always have more elements than the local_list
                new_contributor=[i for i in remote_list if i not in local_list]
                #print new_contributor
                text =  str(new_contributor) + ' ' +  "did his first commit to this repo" %new_contributor
		tweet_at_twitter(text)
                logger(text)
        else:
            remote_list = get_list_contributors()
            sync_to_local(remote_list)

