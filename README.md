ADAPT site

Static site built with Zola (https://www.getzola.org) and hosted on AWS S3.

Edit content
  content/_index.md            front page text
  content/themes.md            research themes
  content/projects/*.md        one file per project
  content/opportunities/*.md   one file per fellowship or award type
  content/people.md            steering committee and advisory board
  content/contact.md           contact details
Every file starts with a +++ block (title, weight for ordering) and then plain Markdown.
HTML comments mark places where text is still to be confirmed.

Preview locally
  zola serve        then open http://127.0.0.1:1111

Build
  zola build        output goes to public/

Deploy
  1. Create an S3 bucket, enable static website hosting, index document index.html,
     and attach a public-read bucket policy (or put CloudFront in front of it).
  2. Set base_url in config.toml to the bucket website endpoint or your custom domain.
  3. ./deploy.sh BUCKET_NAME
