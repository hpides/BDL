"""Relay two model APIs with live output and optional per-reply CSV metrics."""

import argparse
from contextlib import nullcontext
import csv
from datetime import datetime, timezone
from http.client import HTTPException
import json
from pathlib import Path
import sys
from time import perf_counter
from urllib.error import URLError
from urllib.request import Request, urlopen


CSV_FIELDS = [
    "turn", "agent", "agent_turn", "started_at", "status", "no_cache",
    "elapsed_s", "first_text_s", "generated_words", "total_generated_words",
]


def request_json(url, payload=None):
    data = None if payload is None else json.dumps(payload).encode("utf-8")
    request = Request(url, data=data, headers={"Content-Type": "application/json"})
    with urlopen(request, timeout=180) as response:
        return json.load(response)


def request_stream(url, payload, receive):
    """Print each SSE content delta on arrival; use usage if the API supplies it."""
    request = Request(url, data=json.dumps(payload).encode("utf-8"), headers={
        "Content-Type": "application/json", "Accept": "text/event-stream",
    })
    usage = {}
    with urlopen(request, timeout=180) as response:
        for raw_line in response:
            line = raw_line.decode("utf-8").strip()
            if not line.startswith("data:"):
                continue
            data = line[5:].strip()
            if data == "[DONE]":
                return usage
            event = json.loads(data)
            if "error" in event:
                raise ValueError(f"API streaming error: {event['error']}")
            if isinstance(event.get("usage"), dict):
                usage.update(event["usage"])
            choices = event.get("choices", [])
            if choices:
                content = choices[0].get("delta", {}).get("content")
                if content is not None and content != "":
                    if not isinstance(content, str):
                        raise ValueError("API returned a non-text streaming delta")
                    receive(content)
    raise ValueError("API stream ended before [DONE]; reply was incomplete")


def converse(urls, personas, question, max_tokens, no_cache=False, stream=True, csv_file=None):
    models = [request_json(url + "/models")["data"][0]["id"] for url in urls]
    histories = [[{"role": "system", "content": persona}] for persona in personas]
    pad_system = [False, False]
    turns = [0, 0]
    words = [0, 0]
    writer = csv.DictWriter(csv_file, fieldnames=CSV_FIELDS) if csv_file is not None else None
    if writer:
        writer.writeheader()
        csv_file.flush()
    incoming = question
    index = 0
    while True:
        history = histories[index]
        if no_cache:
            # v0.16.3 matches cached prefixes by exact message strings.
            # Alternate independently per API so successive requests differ.
            history[0]["content"] = personas[index] + (" " if pad_system[index] else "")
            pad_system[index] = not pad_system[index]
        history.append({"role": "user", "content": incoming})
        turns[index] += 1
        payload = {"model": models[index], "messages": history,
                   "max_tokens": max_tokens, "stream": stream}
        parts = []
        first_text = None
        status = "error"
        started_at = datetime.now(timezone.utc).isoformat()
        print(f"\n{'A' if index == 0 else 'B'}:", flush=True)
        start = perf_counter()

        def receive(piece):
            nonlocal first_text
            if first_text is None:
                first_text = perf_counter() - start
            parts.append(piece)
            print(piece, end="", flush=True)

        try:
            url = urls[index] + "/chat/completions"
            if stream:
                request_stream(url, payload, receive)
            else:
                result = request_json(url, payload)
                reply = result["choices"][0]["message"]["content"]
                if not isinstance(reply, str) or not reply.strip():
                    raise ValueError("API returned an empty reply; inspect its server log")
                receive(reply)
            reply = "".join(parts)
            if not reply.strip():
                raise ValueError("API returned an empty reply; inspect its server log")
            status = "ok"
        except KeyboardInterrupt:
            status = "interrupted"
            raise
        finally:
            elapsed = perf_counter() - start
            print(flush=True)
            generated_words = len("".join(parts).split())
            words[index] += generated_words
            if writer:
                writer.writerow({
                    "turn": sum(turns), "agent": "AB"[index], "agent_turn": turns[index],
                    "started_at": started_at, "status": status, "no_cache": no_cache,
                    "elapsed_s": round(elapsed, 6),
                    "first_text_s": round(first_text, 6) if first_text is not None else None,
                    "generated_words": generated_words, "total_generated_words": sum(words),
                })
                csv_file.flush()
        history.append({"role": "assistant", "content": reply})
        incoming = reply
        index = 1 - index


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--api-a", default="http://10.0.0.1:9998/v1")
    parser.add_argument("--api-b", default="http://10.0.0.3:9998/v1")
    parser.add_argument("--role-a", required=True, help="System prompt for A")
    parser.add_argument("--role-b", required=True, help="System prompt for B")
    parser.add_argument("--question", required=True, help="Opening user message to A")
    parser.add_argument("--max-tokens", type=int, default=512, help="Maximum new tokens per reply (default: 512)")
    parser.add_argument("--no-cache", action="store_true",
                        help="Force prefix-cache misses by alternating a trailing system-prompt space per API")
    parser.add_argument("--no-stream", action="store_true", help="Print complete replies instead of live text")
    parser.add_argument("--csv", type=Path, help="Write per-reply and cumulative metrics to a new CSV file")
    args = parser.parse_args(argv)
    urls = [args.api_a.rstrip("/"), args.api_b.rstrip("/")]
    if urls[0] == urls[1]:
        parser.error("Supply two different API endpoints")
    if args.max_tokens < 1:
        parser.error("--max-tokens must be positive")
    try:
        if args.csv:
            args.csv.parent.mkdir(parents=True, exist_ok=True)
        with (args.csv.open("x", newline="", encoding="utf-8") if args.csv else nullcontext(None)) as csv_file:
            converse(urls, [args.role_a, args.role_b], args.question, args.max_tokens,
                     no_cache=args.no_cache, stream=not args.no_stream, csv_file=csv_file)
    except KeyboardInterrupt:
        print("\nConversation stopped.", file=sys.stderr)
        return 130
    except (URLError, OSError, HTTPException, ValueError, KeyError, IndexError, TypeError) as error:
        print(f"Conversation stopped: {error}. Check the API server logs and CSV path.", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
