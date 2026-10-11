#!/usr/bin/env python3
"""Serve the web build locally with caching turned off.

  python tool/serve.py            # http://localhost:8080
  python tool/serve.py 9000 --lan # other port, reachable from phones on the same Wi-Fi

`python -m http.server` lets the browser keep old copies of main.dart.js, so a
fresh build can look unchanged. This sends Cache-Control: no-store on every
file, so a normal reload always shows the latest build.
"""
import functools
import http.server
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WEB = os.path.join(ROOT, 'build', 'web')


class NoCache(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, must-revalidate')
        self.send_header('Expires', '0')
        super().end_headers()


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    port = int(args[0]) if args else 8080
    host = '0.0.0.0' if '--lan' in sys.argv else '127.0.0.1'
    if not os.path.exists(os.path.join(WEB, 'index.html')):
        sys.exit('No build found - run: flutter build web')
    handler = functools.partial(NoCache, directory=WEB)
    with http.server.ThreadingHTTPServer((host, port), handler) as srv:
        print(f'Serving {WEB} at http://localhost:{port} (no cache). Ctrl+C to stop.')
        srv.serve_forever()


if __name__ == '__main__':
    main()
