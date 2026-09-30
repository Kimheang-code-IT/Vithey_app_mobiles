"""Central logging for the Vithey AI core.

Every module obtains its logger through ``get_logger`` so output is
consistent and controllable via the ``LOG_LEVEL`` env var.
"""

import logging
import sys

from .config import Config

_CONFIGURED = False


def _configure_root() -> None:
    global _CONFIGURED
    if _CONFIGURED:
        return
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(
        logging.Formatter(
            fmt="%(asctime)s %(levelname)s %(name)s - %(message)s",
            datefmt="%Y-%m-%dT%H:%M:%S",
        )
    )
    root = logging.getLogger("vithey_ai")
    root.addHandler(handler)
    level = getattr(logging, Config.LOG_LEVEL, logging.INFO)
    root.setLevel(level)
    root.propagate = False
    _CONFIGURED = True


def get_logger(name: str) -> logging.Logger:
    """Return a namespaced logger, e.g. ``get_logger("extraction")``."""
    _configure_root()
    short = name.split(".")[-1]
    if not short.startswith("vithey_ai"):
        short = f"vithey_ai.{short}"
    return logging.getLogger(short)
