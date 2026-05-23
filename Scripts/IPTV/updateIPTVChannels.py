#!/usr/bin/python3
# -*- coding: utf-8 -*-
import sys, os
import sqlite3
import pathlib
from PIL import Image
import requests
import json
import time

class IPTVChannelUpdater():
    def __init__(self):
        self.dbConnection = None

        self.dataPath = pathlib.Path().home().joinpath('.mythqml', 'iptv')
        self.iconPath = pathlib.Path().home().joinpath('.mythqml', 'iptv', 'icons')

        # create our directories to save the data to if it does not exist
        self.dataPath.mkdir(parents=True, exist_ok=True)
        self.iconPath.mkdir(parents=True, exist_ok=True)

        self.checkDatabase()

        self.secrets = self.read_secrets("secrets.json")

    def read_secrets(self, file_path):
        """Read secrets from file."""
        try:
            with open(file_path, "r", encoding="UTF-8") as file:
                return json.load(file)
        except FileNotFoundError:
            print(f"Error: Secrets file not found at {file_path}")
            return {}
        except json.JSONDecodeError:
            print(f"Error: Unable to decode JSON in {file_path}")
            return {}

    def checkDatabase(self):
        # create the iptvchannels database if it doesn't exist
        dbPath = self.dataPath.joinpath('iptvchannels.db')

        if not dbPath.exists():
            dbPath.touch()

        print(f"Opening iptvchannels database from {str(dbPath)}")

        self.dbConnection = sqlite3.connect(str(dbPath))
        self.dbConnection.row_factory = sqlite3.Row

        c = self.dbConnection.cursor()
        c.execute('''CREATE TABLE IF NOT EXISTS "iptv_channels" (
                    "id"        INT  PRIMARY KEY,
                    "channel"   TEXT NOT NULL,
                    "feed"      TEXT,
                    "title"	    TEXT NOT NULL,
                    "icon"	    TEXT,
                    "player"    TEXT DEFAULT 'Internal',
                    "url"	    TEXT NOT NULL,
                    "genre"	    TEXT,
                    "countries"	TEXT,
                    "languages"	TEXT,
                    "xmltvid"	TEXT,
                    "xmltvurl"	TEXT
                );''')

        c.execute('''CREATE TABLE IF NOT EXISTS "languages" (
                    "code"	    TEXT NOT NULL,
                    "name"	    TEXT NOT NULL,
                    PRIMARY KEY("code")
                );''')

        c.execute('''CREATE TABLE IF NOT EXISTS "categories" (
                    "id"	      TEXT NOT NULL,
                    "name"	      TEXT NOT NULL,
                    "description" TEXT NOT NULL,
                    PRIMARY KEY("id")
                );''')

        c.execute('''CREATE TABLE IF NOT EXISTS "countries" (
                    "code"	    TEXT NOT NULL,
                    "name"	    TEXT NOT NULL,
                    "languages" TEXT NOT NULL,
                    "flag"      TEXT NOT NULL,
                    PRIMARY KEY("code")
                );''')

        c.execute('''CREATE TABLE IF NOT EXISTS "streams" (
                    "channel"	  TEXT,
                    "feed"	      TEXT,
                    "title"	      TEXT,
                    "url"	      TEXT,
                    "quality"	  TEXT,
                    "user_agent"  TEXT,
                    "referrer"    TEXT
                );''')

        c.execute('''CREATE TABLE IF NOT EXISTS "guides" (
                    "id"        INT,
                    "channel"   TEXT,
                    "feed"	    TEXT,
                    "site"      TEXT,
                    "site_id"   TEXT,
                    "site_name" TEXT,
                    "lang"      TEXT,
                    PRIMARY KEY("id")
                );''')

        c.execute('''CREATE INDEX IF NOT EXISTS "guide_index" ON "guides" ("channel")''')

        c.execute('''CREATE TABLE IF NOT EXISTS "logos" (
                    "channel"	  TEXT,
                    "feed"	      TEXT,
                    "tags"	      TEXT,
                    "width"	      INT,
                    "height"	  INT,
                    "format"      TEXT,
                    "url"         TEXT
                );''')

        c.execute('''CREATE INDEX IF NOT EXISTS "channel_index" ON "logos" ("channel")''')

        c.execute('''CREATE TABLE IF NOT EXISTS "feeds" (
                    "channel"	      TEXT,
                    "id"	          TEXT,
                    "name"	          TEXT,
                    "alt_names"       TEXT,
                    "is_main"	      TEXT,
                    "broadcast_area"  TEXT,
                    "timezones"       TEXT,
                    "languages"       TEXT,
                    "format"          TEXT
                );''')

        c.execute('''CREATE TABLE IF NOT EXISTS "channels" (
                    "id"	      TEXT,
                    "name"	      TEXT,
                    "alt_names"   TEXT,
                    "network"	  TEXT,
                    "owners"      TEXT,
                    "country"     TEXT,
                    "categories"  TEXT,
                    "is_nsfw"     TEXT,
                    "launched"    TEXT,
                    "closed"      TEXT,
                    "replaced_by" TEXT,
                    "website"     TEXT
                );''')

    def downloadJSON(self, url):
        headers = { "accept": "application/json" }
        try:
            jsonData = requests.get(url, headers=headers)
            categoriesObj = json.loads(jsonData.text)
            return categoriesObj
        except Exception as e:
            print(e)
            return None

    def downloadImage(self, url):
        if url.startswith("https://i.imgur.com/a/"):
            return url

        # download and save the image
        try:
            filename = url.removeprefix('https://i.imgur.com/')
            imagePath = self.iconPath.joinpath(filename)

            # do we already have the image downloaded
            if not imagePath.exists():
                headers = {
                    'Host': 'i.imgur.com',
                    'User-Agent': 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:148.0) Gecko/20100101 Firefox/148.0',
                    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                    'Accept-Language': 'en-GB,en;q=0.9',
                    'Accept-Encoding': 'gzip, deflate, br, zstd',
                    'Referer': 'https://imgur.com/',
                    'Connection': 'keep-alive',
                    'Cookie': 'postpagebeta=1; ana_id=0; is_emerald=0; is_authed=0; user_id=0; IMGURSESSION=eae6e52be0b27b5e73b5f14f1cd4f852; frontpagebetav2=1; WHITELISTED_CLOSED=1',
                    'Upgrade-Insecure-Requests': '1',
                    'Sec-Fetch-Dest': 'document',
                    'Sec-Fetch-Mode': 'navigate',
                    'Sec-Fetch-Site': 'same-site',
                    'Sec-Fetch-User': '?1',
                    'If-Modified-Since': 'Mon, 26 Dec 2022 12:10:04 GMT',
                    'If-None-Match': '2c57ef2aefc7fb7d621f9ca398638e95',
                    'Priority': 'u=0, i'
                }
                r = requests.get(url, headers=headers)
                open(str(imagePath), "wb").write(r.content)
                time.sleep(0.1)

            # verify we have a good image and get the actual format
            imageIsOk = True

            try:
                with Image.open(str(imagePath)) as img:
                    img.verify()
            except (IOError, SyntaxError):
                imageIsOk = False
                print(f"ERROR: failed to verify image - {str(imagePath)}")
                #imagePath.unlink(missing_ok=True)

            if imageIsOk:
                print(f"image is OK: {imagePath.name}")
                return imagePath.name

            return url

        except Exception as e:
            print(f"ERROR: failed to download or save image - {imagePath}")
            print(f"ERROR was: {repr(e)}")
            return url

        return url

    def findLogo(self, id):
        c = self.dbConnection.cursor()
        t = (id,)
        for row in c.execute('''SELECT url FROM logos WHERE channel = ?''', t):
            if row["url"].startswith("https://i.imgur.com/"):
                return self.downloadImage(row["url"])

            return row["url"]

        return None

    def findCountry(self, code):
        c = self.dbConnection.cursor()
        t = (code,)
        for row in c.execute('''SELECT name FROM countries WHERE code = ?''', t):
            return row["name"]

        return None

    def findGuide(self, id):
        c = self.dbConnection.cursor()
        t = (id,)
        for row in c.execute('''SELECT site, site_id  FROM guides WHERE channel = ?''', t):
            return (row["site_id"], row["site"])

        return (None, None)


    def update(self):
        ftpDest = self.secrets["host"]
        ftpUser = self.secrets["username"]
        ftpPassword = self.secrets["password"]

        c = self.dbConnection.cursor()
        c2 = self.dbConnection.cursor()

        #download categories.json
        print("downloading categories...")
        categoriesObj = self.downloadJSON("https://iptv-org.github.io/api/categories.json")

        c.execute('''DELETE FROM categories''')

        catDict = {}
        for category in categoriesObj:
            catDict[category["id"]] = category["name"]
            t = (category["id"], category["name"], category["description"])
            c.execute('''INSERT INTO categories (id, name, description) VALUES (?,?,?)''', t)

        jsonFile = str(self.dataPath.joinpath('categories.json'))
        with open(jsonFile, 'w', encoding='utf-8') as f:
            f.write(json.dumps(categoriesObj, indent=4))

        # deploy the json file to the website
        command = f'''curl -T '{jsonFile}' --user '{ftpUser}:{ftpPassword}' {ftpDest}'''
        print(command)

        os.system(command)

        # download languages.json
        print("downloading languages...")
        languageObj = self.downloadJSON("https://iptv-org.github.io/api/languages.json")

        c.execute('''DELETE FROM languages''')

        langDict = {}
        for language in languageObj:
            langDict[language["code"]] = language["name"]
            t = (language["code"], language["name"])
            c.execute('''INSERT INTO languages (code, name) VALUES (?,?)''', t)

        jsonFile = str(self.dataPath.joinpath('languages.json'))
        with open(jsonFile, 'w', encoding='utf-8') as f:
            f.write(json.dumps(languageObj, indent=4))

        # deploy the json file to the website
        command = f'''curl -T '{jsonFile}' --user '{ftpUser}:{ftpPassword}' {ftpDest}'''
        os.system(command)

        # download countries.json
        print("downloading countries...")
        countriesObj = self.downloadJSON("https://iptv-org.github.io/api/countries.json")

        c.execute('''DELETE FROM countries''')

        for country in countriesObj:
            t = (country["name"], country["code"], json.dumps(country["languages"]), country["flag"])
            c.execute('''INSERT INTO countries (name, code, languages, flag) VALUES (?,?,?,?)''', t)

        jsonFile = str(self.dataPath.joinpath('countries.json'))
        with open(jsonFile, 'w', encoding='utf-8') as f:
            f.write(json.dumps(countriesObj, indent=4))

        # deploy the json file to the website
        command = f'''curl -T '{jsonFile}' --user '{ftpUser}:{ftpPassword}' {ftpDest}'''
        os.system(command)

        # download streams.json
        print("downloading streams...")
        streamObj = self.downloadJSON("https://iptv-org.github.io/api/streams.json")

        c.execute('''DELETE FROM streams''')

        for stream in streamObj:
            t = (stream["channel"], stream["feed"], stream["title"], stream["url"], stream["quality"], stream["user_agent"], stream["referrer"])
            c.execute('''INSERT INTO streams (channel, feed, title, url, quality, user_agent, referrer) VALUES (?,?,?,?,?,?,?)''', t)

        jsonFile = str(self.dataPath.joinpath('streams.json'))
        with open(jsonFile, 'w', encoding='utf-8') as f:
            f.write(json.dumps(streamObj, indent=4))

        # deploy the json file to the website
        command = f'''curl -T '{jsonFile}' --user '{ftpUser}:{ftpPassword}' {ftpDest}'''
        os.system(command)

        # download guides.json
        print("downloading guides...")
        guidesObj = self.downloadJSON("https://iptv-org.github.io/api/guides.json")

        c.execute('''DELETE FROM guides''')

        for guide in guidesObj:
            t = (guide["channel"], guide["feed"], guide["site"], guide["site_id"], guide["site_name"], guide["lang"])
            c.execute('''INSERT INTO guides (channel, feed, site, site_id, site_name, lang) VALUES (?,?,?,?,?,?)''', t)

        jsonFile = str(self.dataPath.joinpath('guides.json'))
        with open(jsonFile, 'w', encoding='utf-8') as f:
            f.write(json.dumps(guidesObj, indent=4))

        # deploy the json file to the website
        command = f'''curl -T '{jsonFile}' --user '{ftpUser}:{ftpPassword}' {ftpDest}'''
        os.system(command)

        # download logos.json
        print("downloading logos...")
        logosObj = self.downloadJSON("https://iptv-org.github.io/api/logos.json")

        c.execute('''DELETE FROM logos''')

        for logo in logosObj:
            t = (logo["channel"], logo["feed"], json.dumps(logo["tags"]), logo["width"], logo["height"], logo["format"], logo["url"])
            c.execute('''INSERT INTO logos (channel, feed, tags, width, height, format, url) VALUES (?,?,?,?,?,?,?)''', t)

        jsonFile = str(self.dataPath.joinpath('logos.json'))
        with open(jsonFile, 'w', encoding='utf-8') as f:
            f.write(json.dumps(logosObj, indent=4))

        # deploy the json file to the website
        command = f'''curl -T '{jsonFile}' --user '{ftpUser}:{ftpPassword}' {ftpDest}'''
        os.system(command)

        # download feeds.json
        print("downloading feeds...")
        feedsObj = self.downloadJSON("https://iptv-org.github.io/api/feeds.json")

        c.execute('''DELETE FROM feeds''')

        for feed in feedsObj:
            t = (feed["channel"], feed["id"], feed["name"], json.dumps(feed["alt_names"]), feed["is_main"], json.dumps(feed["broadcast_area"]), json.dumps(feed["timezones"]), json.dumps(feed["languages"]), feed["format"])
            c.execute('''INSERT INTO feeds (channel, id, name, alt_names, is_main, broadcast_area, timezones, languages, format) VALUES (?,?,?,?,?,?,?,?,?)''', t)

        jsonFile = str(self.dataPath.joinpath('feeds.json'))
        with open(jsonFile, 'w', encoding='utf-8') as f:
            f.write(json.dumps(feedsObj, indent=4))

        # deploy the json file to the website
        command = f'''curl -T '{jsonFile}' --user '{ftpUser}:{ftpPassword}' {ftpDest}'''
        os.system(command)

        # download channels.json
        print("downloading channels...")
        channelsObj = self.downloadJSON("https://iptv-org.github.io/api/channels.json")

        c.execute('''DELETE FROM channels''')

        for channel in channelsObj:
            t = (channel["id"], channel["name"], json.dumps(channel["alt_names"]), channel["network"], json.dumps(channel["owners"]), channel["country"], json.dumps(channel["categories"]), channel["is_nsfw"], channel["launched"], channel["closed"], channel["replaced_by"], channel["website"])
            c.execute('''INSERT INTO channels (id, name, alt_names, network, owners, country, categories, is_nsfw, launched, closed, replaced_by, website) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)''', t)

        jsonFile = str(self.dataPath.joinpath('channels.json'))
        with open(jsonFile, 'w', encoding='utf-8') as f:
            f.write(json.dumps(channelsObj, indent=4))

        # deploy the json file to the website
        command = f'''curl -T '{jsonFile}' --user '{ftpUser}:{ftpPassword}' {ftpDest}'''
        os.system(command)

        #populate the iptv_channels table
        c.execute('''DELETE FROM iptv_channels''')

        jsonObj = {}
        channels = []

        for row in c.execute('''SELECT s.channel, s.feed, s.title, s.url, f.languages, co.name AS country, c.categories FROM streams s
                                LEFT JOIN feeds f ON s.channel = f.channel AND s.feed = f.id
                                LEFT JOIN channels c ON s.channel = c.id
                                LEFT JOIN countries co ON c.country = co.code
                                WHERE s.channel IS NOT NULL AND s.url IS NOT NULL;'''):
            channel = row["channel"]
            feed = row["feed"]
            name = row["title"]
            url = row["url"]
            icon = self.findLogo(channel)
            player = "Internal"
            countries = row["country"]

            if row["categories"] == None:
                continue

            categories = json.loads(row["categories"])

            catStr = ""
            for cat in categories:
                try:
                    catName = catDict[cat]
                except:
                    catName = "Unknown"

                if catStr == "":
                    catStr = catName
                else:
                    catStr = catStr + ", " + catName

            if catStr == "":
                catStr = "Unknown"

            if row["languages"] == None:
                continue

            languages = json.loads(row["languages"])

            langStr = ""
            for lang in languages:
                try:
                    langName = langDict[lang]
                except:
                    langName = "Unknown"

                if langStr == "":
                    langStr = langName
                else:
                    langStr = langStr + ", " + langName

            (xmltvid , xmltvurl) = self.findGuide(channel)

            t2 = (channel, feed, name, icon, player, url, catStr, countries, langStr, xmltvid, xmltvurl)
            c2.execute('''INSERT INTO iptv_channels (channel, feed, title, icon, player, url, genre, countries, languages, xmltvid, xmltvurl) VALUES (?,?,?,?,?,?,?,?,?,?,?)''', t2)

            jsonChan = {}
            jsonChan["id"] = channel
            jsonChan["title"] = name
            jsonChan["icon"] = icon
            jsonChan["player"] = "Internal"
            jsonChan["url"] = url
            jsonChan["genre"] = catStr
            jsonChan["countries"] = countries
            jsonChan["languages"] = langStr
            jsonChan["xmltvid"] = xmltvid
            jsonChan["xmltvurl"] = xmltvurl
            channels.append(jsonChan)

        # Save (commit) the changes
        self.dbConnection.commit()

        jsonObj = channels
        jsonFile = str(self.dataPath.joinpath('iptv_channels.json'))
        with open(jsonFile, 'w', encoding='utf-8') as f:
            f.write(json.dumps(jsonObj, indent=4))

        # deploy the json file to the website
        command = f'''curl -T '{jsonFile}' --user '{ftpUser}:{ftpPassword}' {ftpDest}'''
        os.system(command)

def main():

    updater = IPTVChannelUpdater()
    updater.update()

    sys.exit(0)

if __name__ == '__main__':
    main()
