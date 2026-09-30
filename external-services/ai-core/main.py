"""Vithey AI CLI — single entry point for developers.

Lets you test and use the Vithey AI core without importing anything:

    python main.py extract --content "..." --source-id post_123
    python main.py generate --posts posts.json --profile profile.json --target-role "Software Engineer Intern"
    python main.py generate --activities activities.json --job-file job.txt
    python main.py serve --port 8100

The API key is read automatically from .env (see .env.example).
All output is clean JSON on stdout; errors go to stderr.
"""

import argparse
import json
import sys
from pathlib import Path

from vithey_ai import ExtractedActivity, RawPost, UserProfile, VitheyAI
from vithey_ai.errors import VitheyAIError


def _read_json_array(path: str) -> list:
    """Read a JSON file and require it to contain an array."""
    data = json.loads(Path(path).read_text(encoding="utf-8"))
    if not isinstance(data, list):
        raise ValueError(f"Expected a JSON array in '{path}', got {type(data).__name__}.")
    return data


def _read_text(path: str) -> str:
    return Path(path).read_text(encoding="utf-8")


def cmd_extract(args: argparse.Namespace) -> int:
    ai = VitheyAI(api_key=args.api_key)
    activity = ai.extract_activity(
        content=args.content,
        source_id=args.source_id,
        source_type=args.source_type,
    )
    print(json.dumps(activity.model_dump(), ensure_ascii=False, indent=2))
    return 0


def cmd_generate(args: argparse.Namespace) -> int:
    ai = VitheyAI(api_key=args.api_key)

    profile = None
    if args.profile:
        profile_data = json.loads(_read_text(args.profile))
        profile = UserProfile(**profile_data)

    job_description = args.job_description or (
        _read_text(args.job_file) if args.job_file else ""
    )

    if args.posts:
        posts = [RawPost(**item) for item in _read_json_array(args.posts)]
        cv = ai.build_cv_from_raw_posts(
            posts=posts,
            profile=profile,
            target_role=args.target_role,
            job_description=job_description,
            language=args.language,
            on_error=args.on_error,
        )
    else:
        activities = [
            ExtractedActivity(**item) for item in _read_json_array(args.activities)
        ]
        cv = ai.generate_cv(
            activities=activities,
            profile=profile,
            target_role=args.target_role,
            job_description=job_description,
            language=args.language,
        )

    output = {"cv": cv.model_dump()}
    if args.with_quality:
        output["quality"] = ai.quality_report(cv).model_dump()
    print(json.dumps(output, ensure_ascii=False, indent=2))
    return 0


def cmd_serve(args: argparse.Namespace) -> int:
    try:
        import uvicorn
    except ImportError:
        print(
            "Error: the HTTP server needs the 'server' extra: "
            'pip install -e ".[server]"',
            file=sys.stderr,
        )
        return 1

    from vithey_ai.api.app import create_app

    uvicorn.run(create_app(), host=args.host, port=args.port)
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="vithey-ai",
        description=(
            "Vithey AI core CLI: extract structured activities from posts "
            "and generate standard professional CVs."
        ),
    )
    parser.add_argument(
        "--api-key",
        default=None,
        help="Override DEEPSEEK_API_KEY. By default it is read from .env.",
    )

    subparsers = parser.add_subparsers(dest="command", required=True, metavar="COMMAND")

    # --- extract -----------------------------------------------------------
    extract = subparsers.add_parser(
        "extract", help="Extract structured activity data from raw post text."
    )
    extract.add_argument("--content", required=True, help="Raw post/activity text.")
    extract.add_argument("--source-id", required=True, help="Unique id of the source post.")
    extract.add_argument(
        "--source-type", default="post", help="Type of the source (default: post)."
    )
    extract.set_defaults(func=cmd_extract)

    # --- generate ----------------------------------------------------------
    generate = subparsers.add_parser(
        "generate",
        help="Generate a standard CV from extracted activities or raw posts.",
    )
    inputs = generate.add_mutually_exclusive_group(required=True)
    inputs.add_argument(
        "--activities",
        help="Path to a JSON file: array of extracted activities (see ExtractedActivity).",
    )
    inputs.add_argument(
        "--posts",
        help="Path to a JSON file: array of raw posts (source_id, content, optional source_type).",
    )
    generate.add_argument("--profile", help="Path to profile JSON (UserProfile shape).")
    generate.add_argument("--target-role", default="", help="Target role for the CV.")
    generate.add_argument(
        "--job-description", default="", help="Job ad text to tailor the CV towards."
    )
    generate.add_argument(
        "--job-file", help="Path to a plain-text file containing the job description."
    )
    generate.add_argument(
        "--language", default="en", help="CV language: 'en' or 'km' (default: en)."
    )
    generate.add_argument(
        "--on-error",
        choices=["skip", "fail"],
        default="skip",
        help="Skip failed post extraction (default) or abort on first failure.",
    )
    generate.add_argument(
        "--with-quality",
        action="store_true",
        help="Include the deterministic quality report next to the CV.",
    )
    generate.set_defaults(func=cmd_generate)

    # --- serve ---------------------------------------------------------------
    serve = subparsers.add_parser(
        "serve", help="Serve the core over HTTP (FastAPI + uvicorn)."
    )
    serve.add_argument("--host", default="127.0.0.1")
    serve.add_argument("--port", type=int, default=8100)
    serve.set_defaults(func=cmd_serve)

    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        return args.func(args)
    except VitheyAIError as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1
    except json.JSONDecodeError as e:
        print(f"Error: invalid JSON in input file: {e}", file=sys.stderr)
        return 1
    except ValueError as e:
        # Also catches pydantic ValidationError and the missing API key error.
        print(f"Error: {e}", file=sys.stderr)
        return 1
    except FileNotFoundError as e:
        print(f"Error: file not found: {e.filename}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
