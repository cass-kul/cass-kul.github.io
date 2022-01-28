# CASS Website

This is the repository with the source files for the website of the course CASS. We build it with the awesome [Just the docs theme](https://github.com/pmarsceill/just-the-docs). If you found typos or mistakes, please create a PR!

## Files

The website is built directly from Markdown files. You can find the website configuration in `_config.yml` that defines at the end that there are three `collections` of sites: The folder `_course`, `_exercises`, and `_tutorials`.

## Local setup

To test this setup locally, you will probably need `bundler`. Below you can find some links on the whole topic but for a quick start, execute:

```shell
bundle install
bundle exec jekyll serve --incremental
```

The last command will serve the website on `localhost:4000` and incrementally rebuild the site as you change content (keep refreshing the website). Note tha this does not always work if you change the config file, so restart the server if you make major changes to the website.

### Useful links

* <https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/testing-your-github-pages-site-locally-with-jekyll>
* <https://github.com/benbalter/jekyll-remote-theme>
* <https://pmarsceill.github.io/just-the-docs/>
