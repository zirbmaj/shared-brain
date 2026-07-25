#!/usr/bin/env python3
"""
SMS Webhook Relay — receives incoming SMS from SMSGate and posts to Discord.
Runs on mini, listens on port 3870.

SMSGate sends: {event, payload: {phoneNumber, message, receivedAt}, ...}
Discord expects: {content: "text", username: "name"}
"""

import json
import os
import http.server
import urllib.request

DISCORD_WEBHOOK = os.environ.get("SMS_WEBHOOK_URL", "")
CONTACTS_FILE = os.path.expanduser("~/.config/sms-contacts.json")
PORT = 3870

def resolve_contact(phone):
    """Resolve phone number to contact name."""
    try:
        with open(CONTACTS_FILE) as f:
            contacts = json.load(f)
        clean = phone.replace("+1", "").replace("-", "").replace(" ", "")
        for name, number in contacts.items():
            if number.replace("+1", "").replace("-", "").replace(" ", "") == clean:
                return name.title()
    except Exception:
        pass
    return phone

def post_to_discord(content):
    """Post message to Discord webhook."""
    data = json.dumps({"username": "SMS Gateway", "content": content}).encode()
    req = urllib.request.Request(
        DISCORD_WEBHOOK,
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST"
    )
    try:
        urllib.request.urlopen(req, timeout=10)
    except Exception as e:
        print(f"Discord post failed: {e}")

class WebhookHandler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length)
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"ok")

        try:
            data = json.loads(body)
            event = data.get("event", "")
            payload = data.get("payload", {})

            if event == "sms:received":
                phone = payload.get("phoneNumber", "unknown")
                message = payload.get("message", payload.get("text", ""))
                contact = resolve_contact(phone)
                post_to_discord(f"📱 **From: {contact}** ({phone})\n> {message}")
                print(f"SMS from {contact}: {message[:50]}")

            elif event == "system:ping":
                print("SMSGate ping received")

        except Exception as e:
            print(f"Error processing webhook: {e}")

    def log_message(self, format, *args):
        pass  # suppress default logging

if __name__ == "__main__":
    if not DISCORD_WEBHOOK:
        # Load from env file
        try:
            with open(os.path.expanduser("~/.config/sms-gateway.env")) as f:
                for line in f:
                    if line.startswith("SMS_WEBHOOK_URL="):
                        DISCORD_WEBHOOK = line.strip().split("=", 1)[1]
        except Exception:
            pass

    if not DISCORD_WEBHOOK:
        print("ERROR: SMS_WEBHOOK_URL not set")
        exit(1)

    print(f"SMS webhook relay listening on :{PORT}")
    server = http.server.HTTPServer(("0.0.0.0", PORT), WebhookHandler)
    server.serve_forever()
