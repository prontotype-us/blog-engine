# Blog Engine

Serving and querying a blog from markdown on Github

### Example

```coffeescript
blog_engine = require './blog-engine'

# import collection of authors
authors = require './authors'
# point to where your entry files are
entries_dir = './entries'

# who wrote the entries?
entry_authors = {
    "20170601-scalable-software-development-with-the": 't_jones'
}

# what are the topics?
entry_topics = {
    "20170601-scalable-software-development-with-the": ['tutorials', 'webdev', 'copypasta']
}

blog = blog_engine(entries_dir, authors, entry_authors, entry_topics)

module.exports = blog
```
