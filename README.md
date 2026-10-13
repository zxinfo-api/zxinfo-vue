# ZXInfo Vue Frontend

The ZXInfo frontend is a Vue single-page application for searching and browsing the ZXDB catalogue of ZX Spectrum software, hardware, books, and related material. It uses Vue 2, Vue Router, Vuetify, and Axios, and reads catalogue data from the separately hosted ZXInfo API.

Repository: [zxinfo-api/zxinfo-vue](https://github.com/zxinfo-api/zxinfo-vue)

## Features

- Search entries, authors, and publishers; filter results and switch between grid and list views.
- Browse entry details, releases, screenshots and inlays, related entries, books, and links.
- Browse entries by letter and view recent ZXDB additions.
- Browse magazines and their issues.
- Explore connections between programmers, compare ZX81 screen data, view SCR files, and inspect the contents of uploaded TZX files.

## Routes

| Path | Page |
| --- | --- |
| `/` | Home and search |
| `/search` or `/search/:query` | Entry search |
| `/author` or `/author/:query` | Author search |
| `/publisher` or `/publisher/:query` | Publisher search |
| `/details/:entryid` | Entry details |
| `/letter/:letter` | Browse entries by initial |
| `/whatsnew` | Recent entries |
| `/magazines` | Magazine list |
| `/magazines/:name` | Magazine details |
| `/magazines/:name/issues/:issueid` | Magazine issue |
| `/graph/:name1/:name2` | Find a connection between two programmers |
| `/zx81` | ZX81 screen comparison |
| `/scr` | SCR viewer |
| `/tapebrowser` | Inspect an uploaded TZX file |
| `/animated/` | Animated loading page |
| `/testpage` | Test page |

The router uses HTML5 history mode. The production Nginx configuration falls back to `index.html` so direct navigation to application routes works.

## Requirements

- Node.js and npm. The Docker build uses Node.js 20.
- Docker with BuildKit for building the container image.
- Access to the ZXInfo API for search and catalogue data.

## Local development

Install the locked dependencies and start the Vue CLI development server:

```sh
npm ci
npm run serve
```

The development server normally runs at <http://localhost:8080>. The frontend's development API target is currently hard-coded to `http://localhost:8201/v5` in `src/main.js`; the corresponding API service must be available locally for data-backed pages to work.

## Commands

```sh
npm run serve  # Start the development server
npm run build  # Build the production site into dist/
npm run lint   # Run the Vue CLI linter
```

The production build uses Vue CLI's modern build mode. The API base URL is selected in `src/main.js`: development uses `http://localhost:8201/v5`, while production uses `http://api.zxinfo.klaptorsk.dk/v5`. These URLs are currently code constants, not runtime environment settings. Change the appropriate value and rebuild to target another API. If the frontend is served over HTTPS, use an HTTPS API endpoint as well; browsers block HTTP API requests from secure pages as mixed content.

## Docker

Build and run the production image from the repository root:

```sh
docker build -t zxinfo-vue .
docker run --rm --name zxinfo-vue -p 9000:8080 zxinfo-vue
```

Open <http://localhost:9000>. The image builds the app in a Node.js stage using `npm ci`, then serves `dist/` with Nginx on container port `8080`. The image does not terminate TLS; configure HTTPS and host routing in the reverse proxy in front of it.

Alternatively, use the included Compose configuration:

```sh
docker compose up --build -d
docker compose down
```

Compose binds the service to `127.0.0.1:8200`; open <http://localhost:8200> on the Docker host.

## Deployment troubleshooting

- If the page is blank, check the browser console and Network panel. JavaScript and CSS asset requests should return their asset content, not `index.html`.
- The Nginx SPA fallback can return `index.html` with status `200` for a missing asset. A JavaScript request whose response begins with HTML usually means the deployed `dist/` files are incomplete or from different builds. Redeploy the complete build together and purge any proxy or CDN cache.
- Direct links to application routes require the web server or reverse proxy to serve `index.html` for routes that are not static files.
- Data-backed pages also require the configured API to be reachable from the user's browser.
