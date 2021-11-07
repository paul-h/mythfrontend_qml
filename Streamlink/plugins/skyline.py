import re

from streamlink.plugin import Plugin
from streamlink.plugin.api import useragents, validate

class Skyline(Plugin):
    _url_re = re.compile(r'https://www.skylinewebcams.com\/en\/webcam\/.+')
    _video_data_re = re.compile(r"source:[\'\"]?([^\'\"]+)")

    @classmethod
    def can_handle_url(cls, url):
        return Skyline._url_re.match(url)

    def _get_streams(self):
        res = self.session.http.get(self.url, headers={'User-Agent': useragents.FIREFOX})

        match = self._video_data_re.search(res.text)
        if match is None:
            return

        url = match.group(0)
        url = url.replace("source:'", 'https://hd-auth.skylinewebcams.com/')
        url = url.replace("livee.m3u8", 'live.m3u8')

        headers = {
            'User-Agent': useragents.FIREFOX,
            'Referer': url,
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
            'X-Requested-With': 'XMLHttpRequest'
        }

        return self.session.streams(url)

__plugin__ = Skyline
