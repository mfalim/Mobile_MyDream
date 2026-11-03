#!/usr/bin/env python3
"""Server API palsu untuk uji lokal (hanya GET /api/packages). Bukan bagian
aplikasi. Jalankan: python3 tool/fake_api.py"""
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PACKAGES = [
    {
        "id": 1,
        "slug": "paket-intimate-bali",
        "name": "Paket Intimate Bali (dari server palsu)",
        "description": "Data ini datang dari tool/fake_api.py.",
        "availability_date": "2027-03-31",
        "duration": "8.00",
        "event_period": "Akad & Resepsi",
        "guest_capacity": 100,
        "is_featured": 1,
        "price": "95000000.00",
        "vendors": [
            {"id": "vendor-mattana", "name": "Mattana Wedding Planner",
             "category": {"id": 1, "name": "Wedding Planner"},
             "city": "Bali", "price": "45000000.00"},
            {"id": "vendor-sora", "name": "Sora Visual Stories",
             "category": "Photography", "city": "Bali", "price": "18500000.00"},
            {"id": "vendor-ethereal", "name": "Ethereal Glow Bridal MUA",
             "category": "Hair & Makeup", "city": None, "price": "21000000.00"},
        ],
    },
    {
        # Berbentuk data database asli: tanpa harga dan tanpa kolom opsional.
        "id": 2,
        "slug": "paket-tanpa-harga",
        "name": "Paket Tanpa Harga (dari server palsu)",
        "is_featured": 0,
        "vendors": [],
    },
]


class Handler(BaseHTTPRequestHandler):
    def _send(self, status, body):
        data = json.dumps(body).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        path = self.path.split("?")[0].rstrip("/")
        print("GET", self.path, "| Authorization:", self.headers.get("Authorization"))
        if path == "/api/packages":
            return self._send(200, {"data": PACKAGES})
        if path.startswith("/api/packages/"):
            package_id = path.rsplit("/", 1)[1]
            for p in PACKAGES:
                if str(p["id"]) == package_id:
                    return self._send(200, {"data": p})
            return self._send(404, {"message": "Paket tidak ditemukan."})
        self._send(404, {"message": "Tidak ditemukan."})


if __name__ == "__main__":
    print("Server palsu di http://127.0.0.1:8000 (Ctrl+C untuk berhenti)")
    ThreadingHTTPServer(("127.0.0.1", 8000), Handler).serve_forever()