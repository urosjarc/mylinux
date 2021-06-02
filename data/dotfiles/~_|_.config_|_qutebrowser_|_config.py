config.load_autoconfig(False)

c.downloads.location.directory = "/home/USER/Downloads"

c.url.default_page = "https://google.com"
c.url.start_pages = [c.url.default_page]
c.url.searchengines = {
    "DEFAULT": "https://www.google.com/search?q={}",
    "you": "https://youtube.com/results?search_query={}"
}

c.content.geolocation = False
c.content.notifications.enabled = False
c.content.persistent_storage = False

c.tabs.min_width = 100

c.bindings.commands['normal'] = {
    'j': 'scroll-page 0 0.05',
    'k': 'scroll-page 0 -0.05',
    'l': 'scroll-page 0.05 0',
    'h': 'scroll-page -0.05 0',

    '<Alt-L>': "tab-next",
    '<Alt-H>': "tab-prev",
    '<Alt-C>': 'tab-close',

    '<Alt-J>': "back",
    '<Alt-K>': "forward",

    '<Alt-A>': "set-cmd-text :open -t ",

    '<Alt-N>': "search-next",
    '<Alt-U>': "search-prev"

}
