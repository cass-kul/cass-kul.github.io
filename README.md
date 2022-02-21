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

## Added UI tweaks

### Image slider

You can bundle multiple images together and show them in a slider. The slider moves on click or on drag/touch and shows a count at the top. It's a little bit glitchy but should work well enough. We adjusted it from the [gallery-swiper-box/](https://www.cssscript.com/gallery-swiper-box/) which has no license so we just mention it here.

Usage:
1. In the page header, add a collection with links to all images you want to include, like this:
```
gallery_images:
    - stack-album/convention-example-11.png
    - stack-album/convention-example-12.png
```
2. At the point where you want to include the gallery, put the line 
```
{% include gallery.html images=page.gallery_images ratio_image="stack-album/convention-ratios.png" %}
```

This 
1. Includes the `gallery.html` (which may only work once per page right now as it uses an HTML ID to place stuff, adjust this if you want to use it multiple times per page)
1. Mentions the collection by name that you created above
1. Also mentions the background image by path. This image is used to define the dimensions and background of the images and should be just the right size to fit all images.