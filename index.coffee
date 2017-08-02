fs = require 'fs'
moment = require 'moment'
MarkdownIt = require 'markdown-it'
MarkdownItMathjax = require 'markdown-it-mathjax'
hljs = require 'highlight.js'

# Helpers

capitalize = (s) ->
    s[0].toUpperCase() + s.slice(1)

unslugify = (s) ->
    s.replace(/^\d+-/, '')
        .replace('.md', '')
        .replace(/-/g, ' ')
        .split(' ')
        .map(capitalize)
        .join(' ')

# Markdown rendering helpers

md = new MarkdownIt
    html: true
    linkify: true
    highlight: (str, lang) ->
        if lang and hljs.getLanguage(lang)
            try
                return hljs.highlight(lang, str).value
            catch err
                # Do nothing
        else
            return str
        return

md = md.use(MarkdownItMathjax())

module.exports = (authors, entry_authors, entry_topics, {entries_dir, drafts_dir}) ->

    entries_dir ||= "./entries"
    drafts_dir ||= "./drafts"

    listEntries = ->
        entries = fs.readdirSync(entries_dir)
            .filter (filename) -> filename.match(/\.md/)
            .map (filename) =>
                stat = fs.statSync entries_dir + '/' + filename
                Object.assign {stat}, {filename}
            .map (entry) ->
                entry.date = moment(entry.filename.split('-')[0])
                entry.name = unslugify entry.filename
                entry.link = '/' + entry.filename.split('.md')[0]
                return entry

    summarizeEntries = ->
        listEntries().map (entry) =>
            content = fs.readFileSync entries_dir + '/' + entry.filename, 'utf8'
            summary = content.split('\n')
                .filter((l) -> l.match /^[A-Z]/)[0]
            html = md.render summary
            entry.summary = html
            return entry

    getEntry = (req, res) ->
        {slug} = req.params
        date = moment(slug.split('-')[0])
        filename = slug + '.md'
        name = unslugify slug
        content = fs.readFileSync entries_dir + '/' + filename, 'utf8'
        html = md.render content
        author = authors[entry_authors[slug]]
        topics = entry_topics[slug] || []
        {slug, date, name, html, author, topics}

    getDraft = (req, res) ->
        {slug} = req.params
        date = moment(slug.split('-')[0])
        filename = slug + '.md'
        name = unslugify slug
        content = fs.readFileSync drafts_dir + '/' + filename, 'utf8'
        html = md.render content
        author = authors[entry_authors[slug]]
        topics = entry_topics[slug] || []
        {slug, date, name, html, author, topics}

    return {listEntries, summarizeEntries, getEntry, getDraft}
