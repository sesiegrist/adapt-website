# ADAPT website

Static site for ADAPT, built with [Zola](https://www.getzola.org/) and deployed to AWS S3 + CloudFront on every push to `main`.

Live site: https://adaptbiology.org

## Editing content

Everything a visitor reads lives under `content/` as Markdown:

| Path | What it is |
|---|---|
| `content/_index.md` | Front page text |
| `content/research.md` | Research themes |
| `content/projects/*.md` | One file per project |
| `content/opportunities/*.md` | One file per fellowship or award |
| `content/people/*.md` | One file per person (`group` picks the section) |
| `content/news/YYYY-MM-DD-slug.md` | One file per news item |
| `content/contact.md` | Contact page |

Each file starts with a `+++` block (title, ordering, extras) followed by plain Markdown. HTML comments (`<!-- ... -->`) mark text still to be confirmed and are invisible on the site.

The menu is set in `config.toml` under `[extra] menu`. Colours are the six values at the top of `sass/style.scss`.

Images go in `static/images/` and are referenced as `images/...` in front matter or `/images/...` in Markdown.

## Previewing locally

Install Zola (`brew install zola` on macOS), then from the repo root:

```bash
zola serve
```

Open http://127.0.0.1:1111. The site rebuilds when you save a file.

## Publishing

Pushing to `main` runs `.github/workflows/deploy.yml`, which builds the site in a Zola container, syncs `public/` to S3 with per-type cache headers, and invalidates CloudFront.

```bash
git add -A
git commit -m "Short description of the change"
git push origin main
```

Watch progress under the repository's **Actions** tab. Allow a minute or two for CloudFront after it succeeds.

### Required repository secrets

Settings → Secrets and variables → Actions:

| Secret | Value |
|---|---|
| `S3_BUCKET` | bucket name, e.g. `adaptbiology.org` |
| `AWS_ACCESS_KEY_ID` | IAM access key for a deploy-only user |
| `AWS_SECRET_ACCESS_KEY` | its secret |
| `AWS_REGION` | e.g. `us-east-1` |
| `CLOUDFRONT_DISTRIBUTION_ID` | the distribution in front of the bucket |

## One-time AWS setup

Done once, in the AWS console, all in `us-east-1` (CloudFront certificates must be there).

1. **Domain.** Route 53 → Registered domains → Register `adaptbiology.org`. A hosted zone is created automatically.
2. **Certificate.** Certificate Manager → Request → public certificate for `adaptbiology.org` and `www.adaptbiology.org`, DNS validation. Click "Create records in Route 53". Wait until status is Issued.
3. **Bucket.** S3 → Create bucket named `adaptbiology.org`. Leave "Block all public access" ON. Do not enable static website hosting; CloudFront will read the bucket privately.
4. **CloudFront.** Create distribution. Origin: the bucket. Origin access: Origin access control (create one). Viewer protocol: Redirect HTTP to HTTPS. Default root object: `index.html`. Alternate domain names: `adaptbiology.org`, `www.adaptbiology.org`. Custom SSL certificate: the one from step 2. After creation, copy the bucket policy CloudFront offers and paste it into the bucket's Permissions → Bucket policy.
5. **Subdirectory index pages.** CloudFront serves `/projects/` only if told to look for `/projects/index.html`. Add a CloudFront Function (Functions → Create → viewer request) with:
   ```js
   function handler(event) {
     var r = event.request;
     if (r.uri.endsWith('/')) r.uri += 'index.html';
     else if (!r.uri.includes('.')) r.uri += '/index.html';
     return r;
   }
   ```
   Publish it and associate it with the distribution's default behavior as a viewer request function.
6. **DNS.** Route 53 → hosted zone → Create record: `adaptbiology.org`, type A, Alias to the CloudFront distribution. Repeat for `www`.
7. **Deploy user.** IAM → Users → Create `adapt-site-deploy`, programmatic access only, with a policy allowing `s3:ListBucket`, `s3:PutObject`, `s3:DeleteObject`, `s3:GetObject` on the bucket and `cloudfront:CreateInvalidation` on the distribution. Create an access key and put it in the GitHub secrets above.

After step 7, push to `main` and the site goes live.
