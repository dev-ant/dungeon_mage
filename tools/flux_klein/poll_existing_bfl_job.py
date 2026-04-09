#!/usr/bin/env python3
import argparse
import json
import os
import pathlib
import time
import urllib.request
from urllib.error import HTTPError, URLError


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Poll an existing BFL job id until ready and download the sample."
    )
    parser.add_argument("--job-id", required=True)
    parser.add_argument("--region", default="eu5")
    parser.add_argument("--output", required=True)
    parser.add_argument("--metadata", required=True)
    parser.add_argument("--log", required=True)
    parser.add_argument("--poll-seconds", type=float, default=10.0)
    parser.add_argument("--max-poll-seconds", type=float, default=60.0)
    args = parser.parse_args()

    api_key = os.environ["BFL_API_KEY"]
    polling_url = f"https://api.{args.region}.bfl.ai/v1/get_result?id={args.job_id}"
    output_path = pathlib.Path(args.output)
    metadata_path = pathlib.Path(args.metadata)
    log_path = pathlib.Path(args.log)
    headers = {"x-key": api_key}

    submit = {
        "id": args.job_id,
        "polling_url": polling_url,
    }

    def log(event: dict) -> None:
        log_path.parent.mkdir(parents=True, exist_ok=True)
        with log_path.open("a", encoding="utf-8") as handle:
            handle.write(json.dumps(event, ensure_ascii=False) + "\n")

    if output_path.exists() and metadata_path.exists():
        log({"event": "already_downloaded", "saved_to": str(output_path)})
        return 0

    delay = args.poll_seconds
    started = time.time()
    attempt = 0
    last_status = None

    while True:
        attempt += 1
        try:
            request = urllib.request.Request(polling_url, headers=headers)
            with urllib.request.urlopen(request, timeout=120) as response:
                data = json.loads(response.read().decode("utf-8"))
        except (URLError, HTTPError) as exc:
            log(
                {
                    "attempt": attempt,
                    "event": "poll_error",
                    "error": str(exc),
                    "elapsed_seconds": round(time.time() - started, 1),
                }
            )
            time.sleep(delay)
            delay = min(delay * 1.2, args.max_poll_seconds)
            continue

        status = data.get("status")
        if status != last_status or attempt % 10 == 0:
            log(
                {
                    "attempt": attempt,
                    "status": status,
                    "elapsed_seconds": round(time.time() - started, 1),
                }
            )
            last_status = status

        if status == "Ready":
            sample_url = data["result"]["sample"]
            output_path.parent.mkdir(parents=True, exist_ok=True)
            if not output_path.exists():
                with urllib.request.urlopen(sample_url, timeout=120) as response:
                    output_path.write_bytes(response.read())
            metadata_path.write_text(
                json.dumps(
                    {
                        "submit": submit,
                        "result": data,
                        "saved_to": str(output_path),
                    },
                    ensure_ascii=False,
                    indent=2,
                ),
                encoding="utf-8",
            )
            log(
                {
                    "event": "downloaded",
                    "saved_to": str(output_path),
                    "metadata": str(metadata_path),
                }
            )
            return 0

        if status in {"Error", "Failed"}:
            log({"event": "terminal_failure", "result": data})
            return 1

        time.sleep(delay)
        delay = min(delay * 1.1, args.max_poll_seconds)


if __name__ == "__main__":
    raise SystemExit(main())
