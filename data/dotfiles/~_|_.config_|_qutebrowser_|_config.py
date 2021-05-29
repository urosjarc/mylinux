config.load_autoconfig(False)

c.downloads.location.directory = "/home/USER/Downloads"

c.url.default_page = "https://google.com"
c.url.start_pages = ["https://gmail.com", "https://calendar.google.com"]
c.url.searchengines = {
    "DEFAULT": "https://www.google.com/search?q={}",
    "you": "https://youtube.com/results?search_query={}"
}

c.bindings.commands['normal'] = {
    'j': 'scroll-page 0 0.5',
    'k': 'scroll-page 0 -0.5',
    'l': 'scroll-page 0.5 0',
    'h': 'scroll-page -0.5 0',

    '<Alt-L>': "tab-next",
    '<Alt-H>': "tab-prev",
    '<Alt-C>': 'tab-close',

    '<Alt-J>': "back",
    '<Alt-K>': "forward",
    '<Alt-F>': 'history',

    '<Alt-A>': "set-cmd-text :open ",
    '<Alt-P>': "set-cmd-text :search ",
    '<Alt-N>': "search-next",
    '<Alt-U>': "search-prev"

}
